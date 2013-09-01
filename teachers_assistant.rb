require 'csv'

class GradeReader
  def self.read_file(file_name)
    mycsv = CSV.read(file_name, headers: true)
    return_data = {}
    mycsv["Student"].each_with_index do |student, index|
      grades_array = mycsv["Grades"][index].split(" ").map { |str| str.to_i }
      return_data[student] = grades_array
    end
    return_data
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
end
#############################################################################
# an object that encapsulates the concept of the class' aggregate performance
#############################################################################
class GradeSummary
end

student_grades = GradeReader.read_file("grades.csv")

puts "Printing Student grades: "
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
