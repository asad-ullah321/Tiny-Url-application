require "cgi"
require "digest"

class TinyUrlController < ApplicationController
  before_action :prepare_create_input, only: :create
  before_action :run_create_prechecks, only: :create

  def home
    @tiny_url = TinyUrl.new
  end

  def create
    tiny_url = if @alias_input.present?
      build_with_user_alias(@alias_input, @original_url)
    else
      build_with_generated_alias(@original_url)
    end

    if tiny_url.is_a?(TinyUrl)
      @generated_short_url = short_url_for(tiny_url.alias)
      @tiny_url = TinyUrl.new
      flash.now[:notice] = "Tiny URL is ready."
      render :home, status: :ok
    else
      flash.now[:alert] = tiny_url
      @tiny_url = TinyUrl.new(original_url: @original_url, alias: @alias_input)
      render :home, status: :unprocessable_entity
    end
  end

  def show
    alias_param = params[:alias].to_s
    tiny_url = TinyUrl.find_by(alias: alias_param)

    if tiny_url
      redirect_to tiny_url.original_url, allow_other_host: true, status: :found
    else
      render :invalid, status: :not_found
    end
  end

  private

  def create_params
    params.require(:tiny_url).permit(:original_url, :alias)
  end

  def prepare_create_input
    @original_url = create_params[:original_url].to_s.strip
    @alias_input = create_params[:alias].to_s.strip
  end

  def run_create_prechecks
    if @original_url.blank?
      flash.now[:alert] = "Original URL can't be blank."
      @tiny_url = TinyUrl.new
      render :home, status: :unprocessable_entity
      return
    end

    return unless @alias_input.present?

    if @alias_input.length > 40
      flash.now[:alert] = "Alias can't be more than 40 characters."
      @tiny_url = TinyUrl.new(original_url: @original_url, alias: @alias_input)
      render :home, status: :unprocessable_entity
      return
    end

    if TinyUrl.exists?(alias: @alias_input)
      flash.now[:alert] = "Alias already exists. Please choose another alias."
      @tiny_url = TinyUrl.new(original_url: @original_url, alias: @alias_input)
      render :home, status: :unprocessable_entity
    end
  end

  def build_with_user_alias(alias_input, original_url)

    tiny_url = TinyUrl.new(alias: alias_input, original_url: original_url)
    return tiny_url if tiny_url.save

    tiny_url.errors.full_messages.to_sentence
  end

  def build_with_generated_alias(original_url)
    existing = TinyUrl.find_by(original_url: original_url)
    return existing if existing

    alias_value = generate_unique_alias(original_url)
    tiny_url = TinyUrl.new(alias: alias_value, original_url: original_url)
    return tiny_url if tiny_url.save

    tiny_url.errors.full_messages.to_sentence
  end

  def generate_unique_alias(original_url)
    Digest::SHA256.hexdigest(original_url)[0, 32] # 128-bit hex
  end

  def short_url_for(alias_value)
    base_url = ENV.fetch("BASE_URL").to_s.chomp("/")
    endpoint = ENV.fetch("GET_ENDPOINT").to_s.gsub(%r{\A/+|/+\z}, "")
    "#{base_url}/#{endpoint}?alias=#{CGI.escape(alias_value)}"
  end
end
