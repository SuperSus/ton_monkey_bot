class PurchasesController < ApplicationController
  include ActionView::RecordIdentifier
  before_action :find_user, only: [:new, :index, :create]
  before_action :find_purchase, only: [:payment, :check]

  def index
  end

  def new
    @purchase = Purchase.new
  end

  def create
    @purchase = @user.purchases.new(purchase_params)

    if @purchase.save
      respond_to do |format|
        format.html { redirect_to payment_purchase_path(@purchase) }
        format.turbo_stream
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def payment
  end

  def check
    CompletePurchasesService.call
    @tried = true
    if Purchase.find_by(comment: @purchase.comment)
      notice = @purchase.completed? ? "Спасибо за покупку!" : "Проверь еще раз!"
      respond_to do |format|
        format.html { redirect_to payment_purchase_path(@purchase), notice: notice }
        format.turbo_stream { flash.now[:notice] = notice }
      end
    else
      render :payment, status: :unprocessable_entity
    end
  end

  private

  def purchase_params
    params.require(:purchase).permit(:quantity)
  end

  def find_purchase
    @purchase = Purchase.find(params.require(:id))
  end

  def find_user
    return @user = User.first if Rails.env.development?

    @user = User.find_by(telegram_id: params[:telegram_id] || params.dig(:user, :telegram_id))
  end
end
