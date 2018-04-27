Spree::Core::Engine.routes.draw do
  namespace 'api' do
    post 'pos_order' => 'pos_order#create', as: :create
  end
  # Add your extension routes here
end
