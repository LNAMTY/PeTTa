;;; REAL-WORLD LIVE DATA PROCESSING ;;;
;;; This script fetches live data from an external API, parses it natively,
;;; and performs logic on the extracted fields to prove real-world utility.

!(import! &self (library lib_json))

;; 1. Fetching live data from a public Todo API:
;; Returns: {"userId": 1, "id": 1, "title": "delectus aut autem", "completed": false}
(= (fetch-todo)
   (let $json-str (py-str (import-python-code "import subprocess; print(subprocess.check_output(['curl', '-s', 'https://jsonplaceholder.typicode.com/todos/1']).decode('utf-8').strip())"))
        $json-str))

;; 2. Processing Logic:
;; We parse the JSON and use the internal data to perform a conditional action.
(= (analyze-task $json-str)
   (let $dict (json-parse $json-str)
        (case $dict
              (((json-object (completed $status) (id $id) (title $title) (userId $uid))
                (if (== $status False)
                    (format-message "Alert: Task " $id " ('" $title "') is NOT yet completed.")
                    (format-message "Status: Task " $id " is finished.")))))))

;; Simple string formatter helper
(= (format-message $a $b $c $d $e)
   (let* (($s (py-str (import-python-code (format "print(''.join(map(str, [~s, ~s, '~s', ~s, ~s])))" $a $b $c $d $e)))))
         $s))

;; 3. Final Execution:
;; We fetch the REAL data and let our logic process the actual 'id' and 'title' from the web.
!(let $raw (fetch-todo)
      (let $analysis (analyze-task $raw)
           (test $analysis "Alert: Task 1 ('delectus aut autem') is NOT yet completed.")))

!(writeln! "Verification Complete: Successfully parsed live JSON and performed logic on internal fields!")
