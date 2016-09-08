require './config/environment'

class ComponentsController < ApplicationController
  get '/components/new' do 
    if is_logged_in?
      erb :'components/create_component'
    else
      redirect to('/login')
    end
  end

  get '/components/:id' do
    if is_logged_in?
      @component = Component.find_by(id: params[:id])
      @category = @component.category
      @user = User.find_by(id: @category.user_id)
      erb :'components/show_component'
    else
      redirect to('/login')
    end
  end

  get '/components/:id/edit' do 
    if is_logged_in?
      @component = Component.find_by(id: params[:id])
      @category = @component.category
      erb :'components/edit_component'
    else
      redirect to('/login')
    end
  end

  get '/components' do
    if is_logged_in?
      @components = Component.all.find_all do |component|
        component.category.user_id == current_user.id 
      end
      erb :'components/components'
    else
      redirect to('/login')
    end
  end

  post '/components' do
    @component = Component.new(name: params[:name], description: params[:description], category_id: params[:category_id])
    if @component.save
      redirect to("/components/#{@component.id}")
    else
      redirect to('/components/new')
    end
  end

  patch '/components/:id/edit' do
    @component = Component.find_by(id: params[:id])
    if @component.update(name: params[:name], description: params[:description], category_id: params[:category_id])
      redirect to("/components/#{params[:id]}")
    else
      redirect to("/components/#{params[:id]}/edit")
    end
  end

  delete '/components/:id/delete' do
    @component = Component.find_by(id: params[:id])
    if is_logged_in? && @component.category.user_id == session[:id]
      @component.destroy
      redirect to('/components')
    else
      redirect to("/components/#{params[:id]}")
    end
  end
end