module LessonDocumentsHelper
  def toc_time(time)
    time.zero? ? raw('&mdash;') : "#{time} mins"
  end
end
