Spree::Core::Engine.routes.draw do
  namespace 'api' do
    post 'pos_order' => 'pos_order#create', as: :create, defaults: { format: 'json' }
  end
  # Add your extension routes here
end
