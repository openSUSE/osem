if @booth_export_option == 'confirmed'
  render 'confirmed_booths'
elsif @booth_export_option == 'all'
  render 'all_booths'
end
