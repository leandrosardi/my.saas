# this function returns a string that describe difference between two times, in a human-friendy way.
# e.g. "3 hours", "2 days"
def htimediff(from, to)
    n = (to - from).to_i
    if n<60
        return "#{n} seconds"
    elsif n<60*60
        return "#{n/60} minutes"
    elsif n<60*60*24
        return "#{n/(60*60)} hours"
    else
        return "#{n/(60*60*24)} days"
    end
end

puts htimediff(
    Time.new(2023, 5, 20, 11, 20, 0),
    Time.new(2023, 6, 20, 11, 20, 21)
)

