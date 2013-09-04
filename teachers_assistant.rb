require 'csv'

class GradeReader
  def self.read_file(file_name)
    if !valid_file?(file_name)
      puts "Invalid file: #{file_name}"
      exit
    end
    mycsv = CSV.read(file_name, headers: true)
    return_data = {}
    mycsv["Student"].each_with_index do |student, index|
      grades_array = mycsv["Grades"][index].split(" ").map { |str| str.to_i }
      return_data[student] = grades_array
    end
    if !valid_data?(return_data)
      puts "Invalid data: #{file_name}"
      exit
    end
    return_data
  end

  def self.valid_file?(file_name)
    return false if !File.exist?(file_name)
    File.extname(file_name) == ".csv"
  end

  def self.valid_data?(student_grades)
    first_size = student_grades.first[1].size
    student_grades.each_value do |grades|
      return false if grades.size != first_size
    end
    return true
  end
end
#############################################################################
# an object that encapsulates the concept of a given assignment grade
#############################################################################
class AssignmentGrade
  attr_reader :grade
  def initialize(grade)
    @grade = grade
  end
end
#############################################################################
# an object that encapsulates the concept of a student's final grade
#############################################################################
class FinalGrade
  def self.letter_grade(grade)
    if grade >= 90
      'A'
    elsif grade >= 80
      'B'
    elsif grade >= 70
      'C'
    elsif grade >= 60
      'D'
    else
      'F'
    end
  end
end
#############################################################################
# an object that represents a participant in a class
#############################################################################
class Student
  attr_reader :first_name, :last_name
  def initialize(first_name, last_name, grades)
    @first_name = first_name
    @last_name = last_name
    @grades = grades
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def average_grade
    return 0 if @grades.size == 0
    (@grades.inject(0) { |sum, grade| sum += grade } / @grades.size.to_f).round(1)
  end

  def letter_grade
    FinalGrade.letter_grade(average_grade)
  end

  def minimum
    @grades.min { |left, right| left <=> right }
  end

  def maximum
    @grades.max { |left, right| left <=> right }
  end

end
#############################################################################
# an object that encapsulates the concept of the class' aggregate performance
#############################################################################
class GradeSummary
  class << self

    def average_score(students)
      return 0 if students.size == 0
      students.inject(0) { |sum, student| sum += student.average_grade } / students.size
    end

    def minimum_score(students)
      (students.min { |left, right| left.minimum <=> right.minimum }).minimum
    end

    def maximum_score(students)
      (students.max { |left, right| left.maximum <=> right.maximum }).maximum
    end

    def standard_deviation(students)
      return 0 if students.size == 0
      class_average = average_score(students)
      averages_squared = students.inject(0) do |sum, student|
        sum += (student.average_grade - class_average)**2
      end
      Math::sqrt(averages_squared / ( students.size - 1 ) )
    end

  end
end

def teach_write(students, file_name)

  sorted_students = students.sort do |left, right|
    if left.last_name == right.last_name
      left.first_name <=> right.first_name
    else
      left.last_name <=> right.last_name
    end
  end

  CSV.open(file_name, "wb") do |csv|
    csv << ["Student", "Average Grade", "Letter Grade"]
    sorted_students.each do |student|
      csv << [student.full_name, student.average_grade, student.letter_grade]
    end
  end

end

puts "What file do you want to read?"
file_name = gets.chomp

student_grades = GradeReader.read_file(file_name)

puts "Printing Student Grades: "
student_grades.each do |student, grades|
  print "#{student}: "
  grades.each { |grade| print "#{grade} " }
  puts
end

puts
puts

students = []
student_grades.each do |full_name, grades|
  first_name = full_name.split(" ")[0]
  last_name = full_name.split(" ")[1]
  students << Student.new(first_name, last_name, grades)
end

students.each do |student|
  puts "#{student.full_name}'s Average Grade is: #{student.average_grade}"
end

puts
puts

students.each do |student|
  puts "#{student.full_name}'s Average Grade is: #{student.letter_grade}"
end

puts
puts

teach_write(students, "report_card.csv")

puts GradeSummary.average_score(students)
puts GradeSummary.maximum_score(students)
puts GradeSummary.minimum_score(students)
puts GradeSummary.standard_deviation(students)

