;;; ispell-ai.el -- spell checker -*- lexical-binding: t; -*-

;; Copyright (C) 2025   Tristan de Cacqueray

;; This file is NOT part of Emacs.

;; This  program is  free  software; you  can  redistribute it  and/or
;; modify it  under the  terms of  the GNU  General Public  License as
;; published by the Free Software  Foundation; either version 2 of the
;; License, or (at your option) any later version.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT  ANY  WARRANTY;  without   even  the  implied  warranty  of
;; MERCHANTABILITY or FITNESS  FOR A PARTICULAR PURPOSE.   See the GNU
;; General Public License for more details.

;; You should have  received a copy of the GNU  General Public License
;; along  with  this program;  if  not,  write  to the  Free  Software
;; Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
;; USA

;; Version: 0.1
;; Author: Tristan de Cacqueray
;; Keywords: spell ai
;; URL: https://github.com/TristanCacqueray/ispell-ai
;; License: GNU General Public License >= 3
;; Package-Requires: ((emacs "29"))

;;; Commentary:

;; M-x ispell-ai
;;
;; TODO: use async command
;;; Code:

;;;###autoload
(defun ispell-ai-region ()
  "Spell check the current region with ai."
  (interactive)
  (unless (region-active-p)
    (error "Region must be active"))
  (shell-command-on-region (region-beginning) (region-end) "ispell-ai" nil t))
