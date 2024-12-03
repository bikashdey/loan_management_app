ActiveAdmin.register AdminUser do
  permit_params :email, :password, :password_confirmation
  config.comments = false
  

  index do
    selectable_column
    id_column
    column :email
    column :created_at
    column :wallet
    actions
  end


  # show do  
  #   attributes_table do
  #     row :email
  #     row :created_at
  #     row :wallet
  #   end
  #   div do
  #     "#{@admin_user.inspect}"
  #   end
  # end


  filter :email

  form do |f|
    f.inputs do
      f.input :email
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end

end
