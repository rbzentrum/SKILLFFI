(setq ffiTimeOut 4)

(if (boundp 'ffiCID)
    (ipcKillProcess ffiCID)
)

(setq ffiCID (ipcSkillProcess "~/workspace/ffiSKILL/skillFFI"))
(setq ffiReady (ipcReadProcess ffiCID ffiTimeOut))

(if (eq ffiReady "ffi ready")
    (printf "%s" "FFI up and running\n")
	(error "FFI ERROR" "Could not launch FFI\n")
)

(defun ffiOpenLib (libName)
	(if (stringp libName) then
		(ipcWriteProcess ffiCID "open\n")
		(if (eq (ipcReadProcess ffiCID ffiTimeOut) "open") then
		    (ipcWriteProcess ffiCID (strcat libName "\n"))
            (ipcReadProcess ffiCID ffiTimeOut)
        else
            (error "FFI ERROR" "TRY RELOADING")
        )
	else
        (error "Expected arguemnt string, gotten %s." (typep libName))
    )
)

(defun ffiDefun (libHandle fnName rType aTypes)
    (cond ((not (stringp libHandle)) (error "libHandle has to be a string instead of %s" (typep libHandle)))
        ((not (stringp fnName)) (error "fnName has to be a string instead of %s" (typep fnName)))
        ((not (stringp rType)) (error "rType has to be a string instead of %s" (typep rType)))
        ((not (listp aTypes)) (error "aTypes has to be a string instead of %s" (typep aTypes)))
        (t 
		    (ipcWriteProcess ffiCID "prep\n")
            (if (eq (ipcReadProcess ffiCID ffiTimeOut) "func") then
                (ipcWriteProcess ffiCID (strcat fnName "\n"))
                (if (eq (ipcReadProcess ffiCID ffiTimeOut) "lib") then
                    (ipcWriteProcess ffiCID (strcat libHandle "\n"))
                    (if (eq (ipcReadProcess ffiCID ffiTimeOut) "rtype") then
                        (ipcWriteProcess ffiCID (strcat rType "\n"))
                        (if (eq (ipcReadProcess ffiCID ffiTimeOut) "numargs") then
                            (sprintf numargs "%d" (length aTypes))
                            (ipcWriteProcess ffiCID (strcat  numargs "\n"))
                            (while (neq aTypes nil)
                                (if (eq (ipcReadProcess ffiCID ffiTimeOut) "atype") then
                                    (ipcWriteProcess ffiCID (strcat (car aTypes) "\n"))
                                    (setq aTypes (cdr aTypes))
                                )
                            )
                            (ipcReadProcess ffiCID ffiTimeOut)
                        else
                            (error "FFI ERROR" "numargs")
                        )
                    else
                        (error "FFI ERROR" "rtype")
                    )
                else
                    (error "FFI ERROR" "lib handle")
                )
            else
                (error "FFI ERROR" "function name")
            )
        )
    )
)

(defun ffiCallfun (fnHandle fnArgs)
    (cond ((not (stringp fnHandle)) (error "fnHandle has to be a string instead of %s" (typep fnHandle)))
        ((not (listp fnArgs)) (error "fnArgs has to be a string instead of %s" (typep fnArgs)))
        (t
            (ipcWriteProcess ffiCID "call\n")
            (if (eq (ipcReadProcess ffiCID ffiTimeOut) "fun") then
                (ipcWriteProcess ffiCID (strcat fnHandle "\n"))
                (while (neq fnArgs nil)
                    (if (eq (ipcReadProcess ffiCID ffiTimeOut) "val") then
                        (setq fnarg (car fnArgs))
                        (if (not (stringp fnarg))
                            (sprintf fnarg "%n" fnarg)
                        )
                        (ipcWriteProcess ffiCID (strcat fnarg "\n"))
                        (setq fnArgs (cdr fnArgs))
                    )
                )
                (ipcReadProcess ffiCID ffiTimeOut)
            else
                (error "FFI ERROR" "calling the function")
            )
        )
    )
)

(defun ffiCloseLib (libHandle)
    (if (eq (ipcWaitForProcess ffiCID) t) then
        (ipcWriteProcess ffiCID "")
        (ipcReadProcess ffiCID)
    else
        (error "Resource Busy...")
    )
)
