Rails.application.routes.draw do
  scope :api do
    scope :v1 do
      resources :balances do
        patch :import, on: :collection
      end
    end
  end
end
