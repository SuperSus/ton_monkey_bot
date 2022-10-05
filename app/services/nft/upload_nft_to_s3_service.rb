# frozen_string_literal: true

module Nft
  class UploadNftToS3Service
    attr_reader :nft, :s3_client

    def initialize(nft:, s3_client: AwsS3Client.new)
      @nft = nft
      @s3_client = s3_client
    end

    class << self
      def batch_upload(nfts, s3_client: AwsS3Client.new)
        uploaded_to_s3_nft_ids = Set.new(s3_client.list_keys(s3_path).filter_map { _1.scan(/\d+/).first.to_i })

        nfts.each { new(nft: _1, s3_client:).call unless uploaded_to_s3_nft_ids.include?(_1.id) }
      end

      def s3_path
        @s3_path ||= "#{S3_FOLDER}/nft"
      end
    end
    delegate :s3_path, to: :class

    def call
      upload_unrevealed_image
      upload_metadata_json
    end

    private

    def upload_metadata_json
      metadata = {
        name: "NFT #{nft.id}",
        image: s3_image_object.public_url,
        attributes: [{ trait_type: 'Type', value: 'Unrevealed' }]
      }
      File.write(tmp_metadata_path, metadata.to_json)

      s3_metadata_object.upload_file(tmp_metadata_path)
    ensure
      File.delete(tmp_metadata_path) if File.file?(tmp_metadata_path)
    end

    def upload_unrevealed_image
      s3_image_object.upload_file(Rails.root.join('nft_deployer/unrevealed.jpeg'))
    end

    def s3_metadata_object
      @s3_metadata_object ||= s3_client.get_object("#{s3_path}/#{nft.id}.json")
    end

    def s3_image_object
      @s3_image_object ||= s3_client.get_object("#{s3_path}/#{nft.id}.jpeg")
    end

    def tmp_metadata_path
      @tmp_metadata_path ||= Rails.root.join('tmp', "#{SecureRandom.uuid}.json").to_s
    end

    def uploaded_to_s3_nft_ids
      @uploaded_to_s3_nft_ids ||= Set.new(s3_client.list_keys(s3_path).filter_map { _1.scan(/\d+/).first.to_i })
    end

    def s3_path
      @s3_path ||= "#{S3_FOLDER}/nft"
    end
  end
end
