class CheckIpJob
  include Sidekiq::Job

  def perform(entry_id, ip)
    # entry:entry_id:incr_num
    ip_keys = $redis_db.keys("entry:#{entry_id}:*")
    ip_values = ip_keys.map { |key| $redis_db.get(key) } unless ip_keys.nil?
    return if ip_values.include?(ip)

    Entry.increment_counter(:view_count, entry_id)
    incr_num = $redis_db.incr('entry_incr')
    $redis_db.setex("entry:#{entry_id}:#{incr_num}", 180, ip)
  end
end
