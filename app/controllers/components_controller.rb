require './config/environment'

class ComponentsController < ApplicationController
  get '/components/new' do 
    if is_logged_in?
      @title = "Create component"
      @categories = Category.all.find_all do |category|
        category.user_id == current_user.id
      end
      erb :'components/create_component'
    else
      redirect to('/login')
    end
  end

  get '/components/:id' do
    if is_logged_in? && @component = Component.find_by(id: params[:id])
      @title = "#{@component.name}"
      erb :'components/show_component'
    elsif is_logged_in?
      redirect to('/components')
    else
      redirect to('/login')
    end
  end

  get '/components/:id/edit' do 
    if is_logged_in? && @component = Component.find_by(id: params[:id])
      @title = "Edit #{@component.name}"
      @categories = Category.all.find_all do |category|
        category.user_id == current_user.id
      end
      erb :'components/edit_component'
    elsif is_logged_in?
      redirect to('/components/:id')
    else
      redirect to('/login')
    end
  end

  get '/components' do
    if is_logged_in?
      @components = Component.all.find_all do |component|
        component.category.user_id == current_user.id 
      end
      @title = "Your components"
      erb :'components/components'
    else
      redirect to('/login')
    end
  end

  post '/components' do
    @component = Component.new(name: params[:name], description: params[:description], category_id: params[:category_id])
    if is_logged_in? && @component.save
      redirect to("/components/#{@component.id}")
    else
      errorArray = []
      @component.errors.messages.each do |key, value|
        value.each do |warning|
          errorArray << "#{key.capitalize} #{warning}. Please try again."
        end
      end
      flash[:error] = errorArray
      if @component.errors.messages[:name].empty?
        flash[:name] = params[:name]
      end
      if @component.errors.messages[:description].empty?
        flash[:description] = params[:description]
      end
      if @component.errors.messages[:category_id].empty?
        flash[:category_id] = params[:category_id]
      end
      redirect to('/components/new')
    end
  end

  patch '/components/:id/edit' do
    @component = Component.find_by(id: params[:id])
    if is_logged_in? && @component.category.user_id == session[:id] && @component.update(name: params[:name], description: params[:description], category_id: params[:category_id])
      redirect to("/components/#{params[:id]}")
    else
      errorArray = []
      @component.errors.messages.each do |key, value|
        value.each do |warning|
          errorArray << "#{key.capitalize} #{warning}. Please try again."
        end
      end
      flash[:error] = errorArray
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