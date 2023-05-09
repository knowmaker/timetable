require 'pg'
class PagesController < ApplicationController
  def main
  end

  def pupil_tt
    @conn = PG.connect(dbname: 'timetable', user: 'postgres', password: 'av09900990')
    if params[:last_name]!=nil && params[:birth_date]!=nil
    @pupil_tt_ans=@conn.exec("SELECT tt.wd_num, tt.lesson_num, s.title, tt.cab_num
FROM weekday wd, lesson l, timetable tt, subject s
WHERE l.lesson_num=tt.lesson_num AND tt.wd_num=wd.wd_num AND tt.id_subj=s.id_subj
AND tt.grade_num=(SELECT grade_num FROM pupil WHERE last_name='#{params[:last_name].to_s}' AND first_name='#{params[:first_name].to_s}' AND patronymic='#{params[:patronymic].to_s}' AND birth_date='#{params[:birth_date]}') ORDER BY tt.lesson_num, tt.wd_num").values
    end
  end

  def teacher_tt
    @conn = PG.connect(dbname: 'timetable', user: 'postgres', password: 'av09900990')
    @id_ct=@conn.exec("SELECT count(*) FROM teacher WHERE last_name='#{params[:last_name].to_s}' AND first_name='#{params[:first_name].to_s}' AND patronymic='#{params[:patronymic].to_s}'").values
    if params[:last_name]!=nil
      @teacher_tt_ans=@conn.exec("SELECT tc.id_teacher, wd.wd_num, l.lesson_num, COALESCE(s.title, 'ОКНО') as title, tt.cab_num, tt.grade_num
FROM lesson l
CROSS JOIN teacher tc
CROSS JOIN weekday wd
LEFT JOIN timetable tt ON l.lesson_num = tt.lesson_num AND wd.wd_num = tt.wd_num AND tc.id_teacher = tt.id_teacher
LEFT JOIN subject s ON tt.id_subj = s.id_subj
WHERE tc.last_name = '#{params[:last_name].to_s}' AND tc.first_name = '#{params[:first_name].to_s}' AND tc.patronymic = '#{params[:patronymic].to_s}' AND wd.wd_num BETWEEN 1 AND 5 AND l.lesson_num BETWEEN 1 AND 6
ORDER BY tc.id_teacher, wd.wd_num, l.lesson_num;").values
    end
  end

  def bells
    @conn = PG.connect(dbname: 'timetable', user: 'postgres', password: 'av09900990')
    @bell_ans=@conn.exec("SELECT * FROM Lesson ORDER BY 1").values
    if params[:start_time]!=nil
    @conn.exec("WITH RECURSIVE updated_schedule AS (
  SELECT lesson_num, '#{params[:start_time]}'::TIME AS start_time, ('#{params[:start_time]}'::TIME + INTERVAL '45 minutes') AS end_time
  FROM Lesson
  WHERE lesson_num = 1
  UNION ALL
  SELECT l.lesson_num, u.end_time + INTERVAL '#{params[:chill_time].to_i} minutes' AS start_time, (u.end_time + INTERVAL '#{params[:chill_time].to_i} minutes' + INTERVAL '45 minutes') AS end_time
  FROM updated_schedule u
  JOIN Lesson l ON l.lesson_num = u.lesson_num + 1
)
UPDATE Lesson l
SET start_time = u.start_time, end_time = u.end_time
FROM updated_schedule u
WHERE l.lesson_num = u.lesson_num;")
    @bell_ans=@conn.exec("SELECT * FROM Lesson ORDER BY 1").values
    end
  end
  def cabinet_tt
    @conn = PG.connect(dbname: 'timetable', user: 'postgres', password: 'av09900990')
    if params[:cab_num]!=nil
      @cabinet_tt_ans=@conn.exec("SELECT l.lesson_num, s.title, tc.last_name, tc.first_name
FROM Timetable tt
JOIN Lesson l ON tt.lesson_num = l.lesson_num
JOIN Subject s ON tt.id_subj = s.id_subj
JOIN Teacher tc ON tt.id_teacher = tc.id_teacher
JOIN Weekday wd ON tt.wd_num = wd.wd_num
WHERE tt.cab_num = #{params[:cab_num].to_i} AND wd.wd_name='#{params[:day]}'
ORDER BY l.lesson_num
").values
    end
  end
  def workload
    @conn = PG.connect(dbname: 'timetable', user: 'postgres', password: 'av09900990')
    if params[:subj_name]!=nil
      @workload_ans=@conn.exec("SELECT Teacher.last_name, Teacher.first_name, Teacher.patronymic, COUNT(*) AS num_lessons
FROM Timetable
JOIN Teacher ON Timetable.id_teacher = Teacher.id_teacher
JOIN Subject ON Timetable.id_subj = Subject.id_subj AND Subject.title = '#{params[:subj_name]}'
GROUP BY Teacher.id_teacher
ORDER BY num_lessons DESC
LIMIT #{params[:top].to_i}").values
    end
  end
  def transfer
    @conn = PG.connect(dbname: 'timetable', user: 'postgres', password: 'av09900990')
    if params[:last_name]!=nil
      @transfer_ans=@conn.exec("UPDATE Pupil
SET grade_num = (
  SELECT CONCAT(CAST(SUBSTRING(grade_num, '^[0-9]+') AS INTEGER) + 1, SUBSTRING(grade_num, '[^0-9]*$'))
  FROM Pupil
  WHERE last_name = '#{params[:last_name].to_s}' AND first_name = '#{params[:first_name].to_s}' AND patronymic = '#{params[:patronymic].to_s}' AND grade_num = '#{params[:grade].to_s}'
    AND CAST(SUBSTRING(grade_num, '^[0-9]+') AS INTEGER) < 11
)
WHERE last_name = '#{params[:last_name].to_s}' AND first_name = '#{params[:first_name].to_s}' AND patronymic = '#{params[:patronymic].to_s}' AND grade_num = '#{params[:grade].to_s}'
  AND CAST(SUBSTRING(grade_num, '^[0-9]+') AS INTEGER) < 11;
").cmd_tuples
    end
  end
  def subj_in_bg
    @conn = PG.connect(dbname: 'timetable', user: 'postgres', password: 'av09900990')
    if params[:quan]!=nil
      @subj_ans=@conn.exec("SELECT gr.grade_num, gr.quantity,
    (SELECT string_agg(DISTINCT s.title, ', ')
        FROM Subject s
        WHERE s.id_subj IN (SELECT tt.id_subj FROM Timetable tt WHERE tt.grade_num = gr.grade_num)) AS subjects
FROM Grade gr
WHERE gr.quantity > #{params[:quan].to_i};").values
    end
  end
end
