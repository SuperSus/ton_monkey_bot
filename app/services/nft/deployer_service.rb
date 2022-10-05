# frozen_string_literal: true

module Nft
  class DeployerService
    def self.call
      new.call
    end

    def call
      node_process.exec!
    ensure
      handle_output
    end

    private

    def node_process
      @node_process ||= POSIX::Spawn::Child.build('node', 'nft_deployer/index.js', timeout: 60)
    end

    def handle_output
      errors = []
      errors << node_process.out if node_process.out['[Deployer] deployNft error']
      errors << node_process.err if node_process.err.present? && err?(node_process.err)
      errors = errors.join(', ')

      if errors.present?
        Rails.logger.error(errors)
        raise errors
      end

      Rails.logger.info(node_process.out) if node_process.out.present?
    end

    def err?(err)
      return false if err['Start index ${this.deployIndex} bigger than supplied nfts amount'] # ignore already deployed err

      true
    end
  end
end
