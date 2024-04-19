users = ['taro', 'jiro', 'saburo', 'shiro', 'goro']
users.each do |user|
  Account.find_or_create_by!(name: user) do |account|
    account.name = "#{user}"
    account.email = "#{user}@sample.com"
    account.nickname = "#{user}@サンプルアカウント"
    account.password = "password"
  end
end

account = Account.first
