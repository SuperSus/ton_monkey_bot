class PurchasesController < ApplicationController
  include ActionView::RecordIdentifier
  before_action :find_user, only: [:new, :index]
  before_action :find_purchase, only: [:payment]

  def index
  end

  def new
    @purchase = Purchase.new
  end

  def create
    # there is js poller - gets qll wallets transactions + comments -> decrypt comment - purchase_id.complete! -> нотификашка продаоно! апдейтим каунт сколько осталось турбостримы

    @user = User.find_by(telegram_id: params.dig(:user, :telegram_id))
    @purchase = @user.purchases.new(purchase_params)

    if @purchase.save
      flash[:notice] = "Purchase created"
      redirect_to payment_purchase_path(@purchase)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def payment
  end

  private

  def purchase_params
    params.require(:purchase).permit(:quantity)
  end

  def find_purchase
    @purchase = Purchase.find(params.require(:id))
  end

  def find_user
    @user = User.find_by(telegram_id: params[:telegram_id])
  end
end
