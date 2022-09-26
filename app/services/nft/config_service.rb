# frozen_string_literal: true

module Nft
  class ConfigService
    attr_reader :config

    def initialize
      @config = {
        wallet_mnemonic: wallet_config[:mnemonic],
        wallet_type: wallet_config[:type] || 'v4R2',
        wallet_address: wallet_config[:address],
        start_index: -1,

        ton_api_url: 'https://toncenter.com/api/v2/jsonRPC',
        ton_api_key: Rails.application.credentials[:tonweb_api_key],

        collection_content: "#{collection_url}/collection.json",
        collection_base: "#{collection_url}/nft/",
        collection_royalty: nft_deployer_config[:collection_royalty] || 0.05,
        deploy_amount: nft_deployer_config[:deploy_amount] || 0.5,
        topup_amount: nft_deployer_config[:topup_amount] || 0.5
      }
    end
    delegate :[], to: :config

    def dump_to_env_file
      dot_env = config.map { |k, v| "#{k.to_s.upcase}=#{v}" }.join("\n")
      File.write(Rails.root.join('.env').to_s, dot_env)
    end

    private

    def wallet_config
      Rails.application.credentials[:wallet]
    end

    def nft_deployer_config
      Rails.application.credentials[:nft_deployer]
    end

    def collection_url
      @collection_url ||= "#{AwsS3Client.new.bucket_url}/#{Nft::S3_FOLDER}"
    end
  end
end
