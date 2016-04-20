class LessonPresenter < SimpleDelegator
  def units
    curriculums.map do |c|
      parent = c.parent
      parent.curriculum_type == CurriculumType.unit ? parent.resource : nil
    end.compact
  end

  def unit
    @unit ||= units.first
  end

  def subject
    @subject ||= unit.subjects.first
  end

  def grade
    @grade ||= unit.grades.first
  end

  def subject_and_grade_title
    "#{subject.try(:name).try(:titleize)} / #{grade.try(:name)}"
  end

  def tags
    subjects.map(&:name).join(', ')
  end

  def test_curriculums
    curriculums
  end

  def curriculum
    @curriculum ||= curriculums.first
  end

  def next
    @next ||= curriculum.next.try(:resource)
  end

  def previous
    @previous ||= curriculum.previous.try(:resource)
  end

  private

    def h
      ApplicationController.helpers
    end
end
