{-# LANGUAGE PatternSynonyms #-}
{-# OPTIONS_GHC -Wall #-}
module Ex7_3 where

pattern True' :: Bool
pattern True' = True
{-# COMPLETE True', False #-}

f :: Bool -> Int
f False = 1
f True' = 2
f True  = 3

h :: T -> T -> Int
h A1 _ = 1
h _ A1 = 2

data T = A1 | A2 | A3 | A4 | A5 | A6 | A7 | A8 | A9 | A10 | A11 | A12 | A13 | A14 | A15 | A16 | A17 | A18 | A19 | A20 | A21 | A22 | A23 | A24 | A25 | A26 | A27 | A28 | A29 | A30 | A31 | A32 | A33 | A34 | A35 | A36 | A37 | A38 | A39 | A40 | A41 | A42 | A43 | A44 | A45 | A46 | A47 | A48 | A49 | A50 | A51 | A52 | A53 | A54 | A55 | A56 | A57 | A58 | A59 | A60 | A61 | A62 | A63 | A64 | A65 | A66 | A67 | A68 | A69 | A70 | A71 | A72 | A73 | A74 | A75 | A76 | A77 | A78 | A79 | A80 | A81 | A82 | A83 | A84 | A85 | A86 | A87 | A88 | A89 | A90 | A91 | A92 | A93 | A94 | A95 | A96 | A97 | A98 | A99 | A100 | A101 | A102 | A103 | A104 | A105 | A106 | A107 | A108 | A109 | A110 | A111 | A112 | A113 | A114 | A115 | A116 | A117 | A118 | A119 | A120 | A121 | A122 | A123 | A124 | A125 | A126 | A127 | A128 | A129 | A130 | A131 | A132 | A133 | A134 | A135 | A136 | A137 | A138 | A139 | A140 | A141 | A142 | A143 | A144 | A145 | A146 | A147 | A148 | A149 | A150 | A151 | A152 | A153 | A154 | A155 | A156 | A157 | A158 | A159 | A160 | A161 | A162 | A163 | A164 | A165 | A166 | A167 | A168 | A169 | A170 | A171 | A172 | A173 | A174 | A175 | A176 | A177 | A178 | A179 | A180 | A181 | A182 | A183 | A184 | A185 | A186 | A187 | A188 | A189 | A190 | A191 | A192 | A193 | A194 | A195 | A196 | A197 | A198 | A199 | A200 | A201 | A202 | A203 | A204 | A205 | A206 | A207 | A208 | A209 | A210 | A211 | A212 | A213 | A214 | A215 | A216 | A217 | A218 | A219 | A220 | A221 | A222 | A223 | A224 | A225 | A226 | A227 | A228 | A229 | A230 | A231 | A232 | A233 | A234 | A235 | A236 | A237 | A238 | A239 | A240 | A241 | A242 | A243 | A244 | A245 | A246 | A247 | A248 | A249 | A250 | A251 | A252 | A253 | A254 | A255 | A256 | A257 | A258 | A259 | A260 | A261 | A262 | A263 | A264 | A265 | A266 | A267 | A268 | A269 | A270 | A271 | A272 | A273 | A274 | A275 | A276 | A277 | A278 | A279 | A280 | A281 | A282 | A283 | A284 | A285 | A286 | A287 | A288 | A289 | A290 | A291 | A292 | A293 | A294 | A295 | A296 | A297 | A298 | A299 | A300 | A301 | A302 | A303 | A304 | A305 | A306 | A307 | A308 | A309 | A310 | A311 | A312 | A313 | A314 | A315 | A316 | A317 | A318 | A319 | A320 | A321 | A322 | A323 | A324 | A325 | A326 | A327 | A328 | A329 | A330 | A331 | A332 | A333 | A334 | A335 | A336 | A337 | A338 | A339 | A340 | A341 | A342 | A343 | A344 | A345 | A346 | A347 | A348 | A349 | A350 | A351 | A352 | A353 | A354 | A355 | A356 | A357 | A358 | A359 | A360 | A361 | A362 | A363 | A364 | A365 | A366 | A367 | A368 | A369 | A370 | A371 | A372 | A373 | A374 | A375 | A376 | A377 | A378 | A379 | A380 | A381 | A382 | A383 | A384 | A385 | A386 | A387 | A388 | A389 | A390 | A391 | A392 | A393 | A394 | A395 | A396 | A397 | A398 | A399 | A400 | A401 | A402 | A403 | A404 | A405 | A406 | A407 | A408 | A409 | A410 | A411 | A412 | A413 | A414 | A415 | A416 | A417 | A418 | A419 | A420 | A421 | A422 | A423 | A424 | A425 | A426 | A427 | A428 | A429 | A430 | A431 | A432 | A433 | A434 | A435 | A436 | A437 | A438 | A439 | A440 | A441 | A442 | A443 | A444 | A445 | A446 | A447 | A448 | A449 | A450 | A451 | A452 | A453 | A454 | A455 | A456 | A457 | A458 | A459 | A460 | A461 | A462 | A463 | A464 | A465 | A466 | A467 | A468 | A469 | A470 | A471 | A472 | A473 | A474 | A475 | A476 | A477 | A478 | A479 | A480 | A481 | A482 | A483 | A484 | A485 | A486 | A487 | A488 | A489 | A490 | A491 | A492 | A493 | A494 | A495 | A496 | A497 | A498 | A499 | A500 | A501 | A502 | A503 | A504 | A505 | A506 | A507 | A508 | A509 | A510 | A511 | A512 | A513 | A514 | A515 | A516 | A517 | A518 | A519 | A520 | A521 | A522 | A523 | A524 | A525 | A526 | A527 | A528 | A529 | A530 | A531 | A532 | A533 | A534 | A535 | A536 | A537 | A538 | A539 | A540 | A541 | A542 | A543 | A544 | A545 | A546 | A547 | A548 | A549 | A550 | A551 | A552 | A553 | A554 | A555 | A556 | A557 | A558 | A559 | A560 | A561 | A562 | A563 | A564 | A565 | A566 | A567 | A568 | A569 | A570 | A571 | A572 | A573 | A574 | A575 | A576 | A577 | A578 | A579 | A580 | A581 | A582 | A583 | A584 | A585 | A586 | A587 | A588 | A589 | A590 | A591 | A592 | A593 | A594 | A595 | A596 | A597 | A598 | A599 | A600 | A601 | A602 | A603 | A604 | A605 | A606 | A607 | A608 | A609 | A610 | A611 | A612 | A613 | A614 | A615 | A616 | A617 | A618 | A619 | A620 | A621 | A622 | A623 | A624 | A625 | A626 | A627 | A628 | A629 | A630 | A631 | A632 | A633 | A634 | A635 | A636 | A637 | A638 | A639 | A640 | A641 | A642 | A643 | A644 | A645 | A646 | A647 | A648 | A649 | A650 | A651 | A652 | A653 | A654 | A655 | A656 | A657 | A658 | A659 | A660 | A661 | A662 | A663 | A664 | A665 | A666 | A667 | A668 | A669 | A670 | A671 | A672 | A673 | A674 | A675 | A676 | A677 | A678 | A679 | A680 | A681 | A682 | A683 | A684 | A685 | A686 | A687 | A688 | A689 | A690 | A691 | A692 | A693 | A694 | A695 | A696 | A697 | A698 | A699 | A700 | A701 | A702 | A703 | A704 | A705 | A706 | A707 | A708 | A709 | A710 | A711 | A712 | A713 | A714 | A715 | A716 | A717 | A718 | A719 | A720 | A721 | A722 | A723 | A724 | A725 | A726 | A727 | A728 | A729 | A730 | A731 | A732 | A733 | A734 | A735 | A736 | A737 | A738 | A739 | A740 | A741 | A742 | A743 | A744 | A745 | A746 | A747 | A748 | A749 | A750 | A751 | A752 | A753 | A754 | A755 | A756 | A757 | A758 | A759 | A760 | A761 | A762 | A763 | A764 | A765 | A766 | A767 | A768 | A769 | A770 | A771 | A772 | A773 | A774 | A775 | A776 | A777 | A778 | A779 | A780 | A781 | A782 | A783 | A784 | A785 | A786 | A787 | A788 | A789 | A790 | A791 | A792 | A793 | A794 | A795 | A796 | A797 | A798 | A799 | A800 | A801 | A802 | A803 | A804 | A805 | A806 | A807 | A808 | A809 | A810 | A811 | A812 | A813 | A814 | A815 | A816 | A817 | A818 | A819 | A820 | A821 | A822 | A823 | A824 | A825 | A826 | A827 | A828 | A829 | A830 | A831 | A832 | A833 | A834 | A835 | A836 | A837 | A838 | A839 | A840 | A841 | A842 | A843 | A844 | A845 | A846 | A847 | A848 | A849 | A850 | A851 | A852 | A853 | A854 | A855 | A856 | A857 | A858 | A859 | A860 | A861 | A862 | A863 | A864 | A865 | A866 | A867 | A868 | A869 | A870 | A871 | A872 | A873 | A874 | A875 | A876 | A877 | A878 | A879 | A880 | A881 | A882 | A883 | A884 | A885 | A886 | A887 | A888 | A889 | A890 | A891 | A892 | A893 | A894 | A895 | A896 | A897 | A898 | A899 | A900 | A901 | A902 | A903 | A904 | A905 | A906 | A907 | A908 | A909 | A910 | A911 | A912 | A913 | A914 | A915 | A916 | A917 | A918 | A919 | A920 | A921 | A922 | A923 | A924 | A925 | A926 | A927 | A928 | A929 | A930 | A931 | A932 | A933 | A934 | A935 | A936 | A937 | A938 | A939 | A940 | A941 | A942 | A943 | A944 | A945 | A946 | A947 | A948 | A949 | A950 | A951 | A952 | A953 | A954 | A955 | A956 | A957 | A958 | A959 | A960 | A961 | A962 | A963 | A964 | A965 | A966 | A967 | A968 | A969 | A970 | A971 | A972 | A973 | A974 | A975 | A976 | A977 | A978 | A979 | A980 | A981 | A982 | A983 | A984 | A985 | A986 | A987 | A988 | A989 | A990 | A991 | A992 | A993 | A994 | A995 | A996 | A997 | A998 | A999 | A1000
