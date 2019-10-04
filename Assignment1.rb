=begin
    Joshua Annandsingh
    CSC 415
    Assignment 1
=end
class Course
    attr_accessor :course_number, :section_amt, :min_seats, :max_seats, :prereq, :seats, :students_ids
    def initialize(course_number,section_amt,min_seats,max_seats,prereq)
        @course_number = course_number
        @section_amt = section_amt
        @min_seats = min_seats
        @max_seats = max_seats
        @prereq = prereq
        @seats = Array.new(section_amt) { Array.new() } #used to represent sections [section number][Students]
    end
end

class Student
    attr_accessor :id, :amt_of_courses, :choices, :last_course_assigned,:error_message, :courses_Assigned, :prereq_met, :courses_enrolled
    def initialize(id,amt_of_courses,first_chc,scnd_chc,thir_chc,fourth_chc,fif_chc)
        @id = id
        @courses_enrolled = 0
        @amt_of_courses = amt_of_courses
        #splits the pre req met? and course selection
        @first = first_chc.split(":")
        @second = scnd_chc.split(":")
        @third = thir_chc.split(":")
        @fourth = fourth_chc.split(":")
        @fifth = fif_chc.split(":")
        @choices = Array[@first[0],@second[0],@third[0],@fourth[0],@fifth[0]] #choice preferences in order
        @choices.length.times do |i|
            if choices[i].nil?
                choices[i]="0"
            end
        end
        @courses_Assigned = Array.new()
        @error_message = Array.new()
        @last_course_assigned = 0
        @prereq_met= Array[@first[1],@second[1],@third[1],@fourth[1],@fifth[1]] #pre req met? in order
        @prereq_met.length.times do |i|
            if prereq_met[i].nil?
                prereq_met[i]="0"
            end
        end
    end
    def addCourse(course) #adds course to students profile
        @courses_Assigned << course
    end
    def addError(str) #adds error to students profile
        @error_message << str
    end
    def lastCourse(num) #the last course in their preference that they got enrolled in
        @last_course_assigned = num
    end
end

## METHODS ##
def course_bubble_sort(array) #sorting method for courseList by Course Number
   n = array.length
   swapped = true
   while swapped do
     swapped = false
     (n - 1).times do |i|
       if array[i].course_number > array[i + 1].course_number
         array[i], array[i + 1] = array[i + 1], array[i]
     swapped = true
       end
     end
   end
   array
end

def student_bubble_sort(array) #sorting method for studentList by ID
   n = array.length
   swapped = true
   while swapped do
     swapped = false
     (n - 1).times do |i|
       if array[i].id > array[i + 1].id
         array[i], array[i + 1] = array[i + 1], array[i]
     swapped = true
       end
     end
   end
   array
end

def checkSection(course) #checks if sections have room and attempts to balance
    course.seats.length.times do |i| #first fills all sections with minimum seats
        if course.seats[i].length < course.min_seats
            return i
        end
        break if course.seats[i].length < course.min_seats
    end

    course.seats.length.times do |i| #fills until these sections reach maximum
        if course.seats[i].length < course.max_seats
            return i
       end
       break if course.seats[i].length < course.max_seats
    end
    return -1#all sections filled
end

def courseCheck(k,c) #k is index of the student; c is the choice they are currently on
    #binary search


    while c < 5
        middle = $courseList.length / 2
        i = 0
        j = $courseList.length - 1
        #puts("Student #{$studentList[k].id} last course index is #{c}")
        #while they still have choices to pick from
        if $studentList[k].amt_of_courses == 0
            $studentList[k].addError("Preference of course amount requested was 0")
        end
        break if $studentList[k].courses_enrolled == 2 #breaks if student is enrolled in 2 CSC courses
        break if $studentList[k].amt_of_courses == 0
        while i < j

            if $courseList[0].course_number == $studentList[k].choices[c] #could not get search to arrive at 0 index
                middle = 0
                i=0
                j=0
            end
            if $courseList[$courseList.length-1].course_number == $studentList[k].choices[c] #could not get search to arrive at last index
                middle = $courseList.length-1
                i=0
                j=0
            end

          if $courseList[middle].course_number == $studentList[k].choices[c] #A match to a course
            if checkSection($courseList[middle]) == -1
                $studentList[k].addError("All sections filled for #{$courseList[middle].course_number}")
                break #ALL SECTIONS filled
            else
                if $studentList[k].prereq_met[$studentList[k].last_course_assigned] != "N" #If they met pre req
                    $courseList[middle].seats[checkSection($courseList[middle])]  << $studentList[k]
                    c +=1
                    else
                        $studentList[k].addError("Did not meet the Pre Requisite for #{$courseList[middle].course_number}")
                        c +=1

                end


            end


            break if $studentList[k].prereq_met[c] == "N" #moves on to next choice if pre req is not met
            if $studentList[k].amt_of_courses != 1 #if student wants 2 courses; resets the search with next choice
                $studentList[k].courses_enrolled +=1
                middle = $courseList.length / 2
                j = $courseList.length - 1
                i = 0
                #puts "#{middle}#{i}#{j}"
            end
            break


        elsif $courseList[middle].course_number <  $studentList[k].choices[c]
            i = middle + 1
            middle = (i + j) / 2

          else
            j = middle - 1
            middle = (i + j) / 2
          end
        end
        c +=1

    end
    $studentList[k].lastCourse(c)
end

def sectionCheck #checks if any courses have less than minimum seats
    $courseList.length.times do |i|
        $courseList[i].section_amt.times do |j|
            if $courseList[i].seats[j].length < $courseList[i].min_seats
                $courseList[i].seats[j].length.times do |k|
                    $studentList[$studentList.index($courseList[i].seats[j][k])].courses_enrolled -= 1 #removes course from that student
                    courseCheck($studentList.index($courseList[i].seats[j][k]),$studentList[$studentList.index($courseList[i].seats[j][k])].last_course_assigned) #goes to their next choice
                    $studentList[$studentList.index($courseList[i].seats[j][k])].addError("The course #{$courseList[i].course_number} section #{j} did not meet minimum seats")
                end
                if $courseList[i].seats[j].length < $courseList[i].min_seats #if section is under min deletes all students from section
                    $courseList[i].seats[j].clear
                end
            end
        end
    end
end

def addStudentCourses #adds all students who are enrolled in each section to that section
    $courseList.length.times do |i|
        $courseList[i].section_amt.times do |j|
            $courseList[i].seats[j].length.times do |k|
                $studentList[$studentList.index($courseList[i].seats[j][k])].addCourse($courseList[i].course_number)
            end
        end
    end
end

def writeEnrollment

    CSV.open("enrollment.csv", "wb") do |csv|
  csv << ["Course Number", "Section Number", "Students Enrolled","Open Seats","Filled Seats"]
  $courseList.length.times do |i|
      $courseList[i].section_amt.times do |j|
          idList = Array.new()
          $courseList[i].seats[j].length.times do |k|
              idList << $courseList[i].seats[j][k].id
          end
          csv << [$courseList[i].course_number,j+1,idList,$courseList[i].max_seats-$courseList[i].seats[j].length,$courseList[i].seats[j].length]
      end
  end
end
end

def writeStudentList
    CSV.open("students.csv", "wb") do |csv|
        csv << ["PAWS ID","Courses Enrolled","Errors"]
        $studentList.length.times do |i|
            csv << [$studentList[i].id,$studentList[i].courses_Assigned,$studentList[i].error_message]
        end
    end
end


## MAIN ##

require 'csv'
require 'pp'
$courseList = Array.new()
$studentList = Array.new()
## Creates List of Courses ##
cArray = CSV.read("course_constraints.csv",headers:true) #[row][col]
cArray.length.times do |i| #handles nil entries
    5.times do |j|
        if cArray[i][j].nil?
            cArray[i][j]="0"
        end
    end
end
cArray.length.times do |i|
    $courseList << Course.new(cArray[i][0],cArray[i][1].to_i,cArray[i][2].to_i,cArray[i][3].to_i,cArray[i][4])
end

course_bubble_sort($courseList) #sorts Courses by course number


## Creates Lists of Students ##
sArray = CSV.read("student_prefs.csv",headers:true)
sArray.length.times do |i|
    7.times do |j|
        if sArray[i][j].nil?
            sArray[i][j]="0"
        end
    end
end

sArray.length.times do |i|
    $studentList << Student.new(sArray[i][0].to_i,sArray[i][1].to_i,sArray[i][2],sArray[i][3],sArray[i][4],sArray[i][5],sArray[i][6])
end
student_bubble_sort($studentList) #sorts Students by id



$studentList.length.times do |k| #runs the course search for each student
    courseCheck(k,0)
end
sectionCheck() #checks if sections meet minimum
addStudentCourses()
writeEnrollment()
writeStudentList()
