# frozen_string_literal: true

module Nft
  class UploadCollectionToS3Service
    attr_reader :s3_client

    def initialize(s3_client: AwsS3Client.new)
      @s3_client = s3_client
    end

    def call
      upload_image
      upload_cover_image
      upload_metadata_json
    end

    private

    def upload_metadata_json
      return if s3_metadata_object.exists?

      metadata = {
        name: 'SAMPLE COLLECTION 💎',
        description: 'SAMPLE COLLECTION 💎 — a collection',
        image: s3_image_object.public_url,
        cover_image: s3_cover_image_object.public_url
      }
      File.write(tmp_metadata_path, metadata.to_json)

      s3_metadata_object.upload_file(tmp_metadata_path)
    ensure
      File.delete(tmp_metadata_path) if File.file?(tmp_metadata_path)
    end

    def upload_image
      return if s3_image_object.exists?

      s3_image_object.upload_file(Rails.root.join('nft_deployer/collection_img.jpeg'))
    end

    def upload_cover_image
      return if s3_cover_image_object.exists?

      s3_cover_image_object.upload_file(Rails.root.join('nft_deployer/collection_cover_img.jpeg'))
    end

    def s3_metadata_object
      @s3_metadata_object ||= s3_client.get_object("#{s3_path}/collection.json")
    end

    def s3_image_object
      @s3_image_object ||= s3_client.get_object("#{s3_path}/collection_img.jpeg")
    end

    def s3_cover_image_object
      @s3_cover_image_object ||= s3_client.get_object("#{s3_path}/collection_cover_img.jpeg")
    end

    def tmp_metadata_path
      @tmp_metadata_path ||= Rails.root.join('tmp', "#{SecureRandom.uuid}.json").to_s
    end

    def s3_path
      S3_FOLDER
    end
  end
end
