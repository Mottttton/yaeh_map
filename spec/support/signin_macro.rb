module SigninMacro
  def signin_as(account)
    visit new_account_session_path
    fill_in("account_email", with: account.email)
    fill_in("account_password", with: "password")
    click_button "ログイン"
  end
end
