# frozen_string_literal: true

module Nft
  class DeployerService
    def self.call
      new.call
    end

    def call
      node_process.exec!
      handle_error(node_process.err) if node_process.err.present?
      Rails.logger.info(node_process.out)
    end

    private

    def node_process
      @node_process ||= POSIX::Spawn::Child.build('node', 'nft_deployer/index.js')
    end

    def handle_error(err)
      return if err.blank?

      Rails.logger.error(err)
      raise err
    end
  end
end
