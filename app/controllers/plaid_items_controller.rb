class PlaidItemsController < ApplicationController
  before_action :set_plaid_item, only: %i[destroy sync]

  def create
    Current.family.plaid_items.create_from_public_token(
      plaid_item_params[:public_token],
      item_name: item_name,
    )

    redirect_to accounts_path, notice: t(".success")
  end

  def destroy
    @plaid_item.destroy_later
    redirect_to accounts_path, notice: t(".success")
  end

  def sync
    unless @plaid_item.syncing?
      @plaid_item.sync_later
    end

    redirect_to accounts_path
  end

  private
    def set_plaid_item
      @plaid_item = Current.family.plaid_items.find(params[:id])
    end

    def plaid_item_params
      params.require(:plaid_item).permit(:public_token, metadata: {})
    end

    def item_name
      plaid_item_params.dig(:metadata, :institution, :name)
    end
end