;;; =====================================================================
;;  CCH_ColorChange.lsp   (current version: v2)
;;  Custom command: CCH  (Change Color of existing objects)
;;  Companion to CC. CC sets the CURRENT color for NEW objects;
;;  CCH recolors objects that ALREADY exist.
;;
;;  v2: no (command ...) call. Sets each object's Color property via
;;  ActiveX inside one undo mark, to avoid command-dispatcher overhead.
;;  Setting .Color replaces any true-color override with the ACI color.
;;  Objects that refuse the change (locked layer, some Civil 3D object
;;  types) are counted and reported instead of silently ignored.
;;
;;  Usage:  select objects first (or run CCH and select when prompted),
;;          then type CCH <enter> <key> <enter>
;;
;;  Keys:  R Red | G Green | B Blue | Y Yellow | W White | C Cyan
;;         M Magenta | 8 Color8 | 9 Color9 | LA ByLayer | K ByBlock
;;
;;  See README.md for setup, limitations, and validation status.
;; =====================================================================

(vl-load-com)

(defun *cch-error* (msg)
  (if (not (member msg '("Function cancelled" "quit / exit abort")))
    (princ (strcat "\nCCH error: " msg))
  )
  (if *cch-doc*
    (progn
      (vl-catch-all-apply 'vla-endundomark (list *cch-doc*))
      (setq *cch-doc* nil)
    )
  )
  (setq *error* *cch-olderr*)
  (princ)
)

(defun c:CCH ( / ss key clr aci i obj done skipped)

  (setq *cch-olderr* *error*)
  (setq *error* *cch-error*)

  ;; use pre-selected objects if any, otherwise prompt
  (setq ss (ssget "_I"))
  (if (not ss)
    (progn
      (princ "\nSelect objects to recolor: ")
      (setq ss (ssget))
    )
  )

  (if ss
    (progn
      ;; same keyword loop as CC: clr can never leave this loop unset
      (setq clr nil)
      (while (not clr)
        (setq key nil)
        (while (not key)
          (initget "Red Green Blue Yellow White Cyan Magenta 8 9 LA byblocK")
          (setq key (getkword
            "\nNew color [Red/Green/Blue/Yellow/White/Cyan/Magenta/8/9/LA-byLayer/byblocK]: "))
        )
        (setq clr
          (cond
            ((= key "Red") 1)
            ((= key "Green") 3)
            ((= key "Blue") 5)
            ((= key "Yellow") 2)
            ((= key "White") 7)
            ((= key "Cyan") 4)
            ((= key "Magenta") 6)
            ((= key "8") 8)
            ((= key "9") 9)
            ((= key "LA") "BYLAYER")
            ((= key "byblocK") "BYBLOCK")
          )
        )
      )

      ;; ActiveX Color property: 0 = ByBlock, 256 = ByLayer, else ACI
      (setq aci
        (cond
          ((numberp clr) clr)
          ((= clr "BYLAYER") 256)
          (T 0)
        )
      )

      (setq *cch-doc* (vla-get-activedocument (vlax-get-acad-object)))
      (vla-startundomark *cch-doc*)

      (setq i 0 done 0 skipped 0)
      (repeat (sslength ss)
        (setq obj (vlax-ename->vla-object (ssname ss i)))
        (if (vl-catch-all-error-p
              (vl-catch-all-apply 'vla-put-color (list obj aci)))
          (setq skipped (1+ skipped))
          (setq done (1+ done))
        )
        (setq i (1+ i))
      )

      (vla-endundomark *cch-doc*)
      (setq *cch-doc* nil)

      (princ (strcat "\n" (itoa done) " object(s) set to: "
                     (vl-princ-to-string clr)
                     (if (> skipped 0)
                       (strcat "  |  " (itoa skipped)
                               " skipped (locked layer or unsupported type)")
                       "")))
    )
    (princ "\nNothing selected.")
  )

  (setq *error* *cch-olderr*)
  (princ)
)

(princ "\nCCH v2 loaded. Select objects, then CCH + R G B Y W C M 8 9 LA K")
(princ)
