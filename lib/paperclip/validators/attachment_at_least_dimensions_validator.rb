module Paperclip
  module Validators
    class AttachmentAtLeastDimensionsValidator < ActiveModel::EachValidator
      def initialize(options)
        super
      end

      def self.helper_method_name
        :validates_attachment_at_least_dimensions
      end

      def validate_each(record, attribute, value)
        return unless value.queued_for_write[:original]

        begin
          dimensions = Paperclip::Geometry.from_file(value.queued_for_write[:original].path)

          record.errors.add(attribute.to_sym, :dimension, :height, actual_dimension: dimensions.height.to_i, dimension: options[:height]) unless dimensions.height >= options[:height].to_f
          record.errors.add(attribute.to_sym, :dimension, :width, actual_dimension: dimensions.width.to_i, dimension: options[:width]) unless dimensions.width >= options[:width].to_f
        rescue Paperclip::Errors::NotIdentifiedByImageMagickError
          Paperclip.log("cannot validate dimensions on #{attribute}")
        end
      end
    end

    module HelperMethods
      def validates_attachment_dimensions(*attr_names)
        options = _merge_attributes(attr_names)
        validates_with(AttachmentDimensionsValidator, options.dup)
        validate_before_processing(AttachmentDimensionsValidator, options.dup)
      end
    end
  end
end
