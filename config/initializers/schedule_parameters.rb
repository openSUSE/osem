#sanitize the OSEM_SCHEUDLE_CELL_SIZE to be used for EventType::LENGTH_STEP
sched_cell_size = ENV['OSEM_SCHEDULE_CELL_SIZE'].to_i

if (sched_cell_size > 0 and 60 % sched_cell_size == 0)
  SCHEDULE_CELL_SIZE = sched_cell_size
end
