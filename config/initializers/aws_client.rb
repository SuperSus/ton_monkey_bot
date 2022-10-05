options = Rails.application.credentials[:aws] || {}
Aws.config.update(
  access_key_id:     options[:access_key_id],
  secret_access_key: options[:secret_access_key],
  region:            options[:region] || 'eu-west-2',
)

class AwsS3Client
  PUBLIC_READ_ACL = 'public-read'
  DEFAULT_BUCKET = Rails.application.credentials.dig(:aws, :default_bucket) || 'tonmonkey'

  attr_reader :bucket, :client

  def initialize(bucket = DEFAULT_BUCKET, **credentials)
    @bucket = bucket
    @client = Aws::S3::Client.new(credentials)
  end

  # Get array of S3 paths for given prefix
  # @param [String] prefix Search prefix
  # @return [Array[String]]
  def list_keys(prefix)
    client.list_objects_v2(bucket: bucket, prefix: prefix).contents.map(&:key)
  end

  # Get array of S3 public urls for given prefix
  # @param [String] prefix Search prefix
  # @return [Array[String]]
  def list_public_urls(prefix)
    list_keys(prefix).map { |key| get_object(key).public_url }
  end

  # Build S3 object, does not call any S3 api
  # @param [String] s3_path
  # @return [Aws::S3::Object]
  def get_object(s3_path)
    object(s3_path)
  end

  # @param [String] s3_path
  # @return [IO]
  def get_body(s3_path)
    object(s3_path).get.body
  end

  # @param [String] s3_path
  # @return [Aws::S3::Types::DeleteObjectOutput]
  def delete_object(s3_path)
    object(s3_path).delete
  end

  # @param [String] local_path
  # @param [String] s3_path
  # @param [Hash] options See list of available Aws::S3::Client#put_object
  def upload_file(local_path, s3_path, **options)
    object(s3_path).tap { _1.upload_file(local_path, options) }
  end

  # @param [String] s3_target_path
  # @param [String] s3_source_path
  # @return [Aws::S3::Types::CopyObjectOutput]
  def copy_from(s3_target_path, s3_source_path)
    object(s3_target_path).copy_from(bucket: bucket, key: s3_source_path)
  end

  # @return [String]
  def bucket_url
    Aws::S3::Bucket.new(bucket).url
  end

  private

  def object(s3_path)
    Aws::S3::Object.new(bucket, s3_path, client: client)
  end
end
