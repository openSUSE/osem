if @track_export_option == 'confirmed'
  render 'confirmed_tracks'
elsif @track_export_option == 'all'
  render 'all_tracks'
end
