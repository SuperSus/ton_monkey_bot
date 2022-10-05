# frozen_string_literal: true

require 'csv'

module Nft
  class CollectionService
    attr_reader :wallet, :s3_client

    def initialize(wallet: WalletService.new, s3_client: AwsS3Client.new)
      @wallet = wallet
      @s3_client = s3_client
    end

    def prepare_and_deploy
      ensure_dot_env_file
      dump_nfts_to_csv

      upload_collection_data_to_s3
      upload_nfts_to_s3

      deploy
    end

    def deploy
      DeployerService.call
    end

    def upload_collection_data_to_s3
      UploadCollectionToS3Service.new.call
    end

    def ensure_dot_env_file
      ConfigService.new.dump_to_env_file
    end

    def upload_nfts_to_s3
      UploadNftToS3Service.batch_upload(nfts)
    end

    # Creates/Refreshes nft.csv (needed for nft_deployer)
    def dump_nfts_to_csv
      CSV.open("#{Rails.root}/nfts.csv", 'w') do |writer|
        nfts.each { writer << [_1.id, _1.address] }
      end
    end

    private

    def nfts
      @nfts ||= build_nfts
    end

    # rewrite through purchases
    def build_nfts
      id = 0
      Purchase.completed.where(comment: wallet.transactions.map(&:comment)).flat_map do |purchase|
        purchase.quantity.times.map do
          OpenStruct.new(id:, address: purchase.wallet_address).tap { id += 1 }
        end
      end
    end
  end
end
