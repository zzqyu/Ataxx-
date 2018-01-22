#!/bin/bash
Login_Out_bnt_string=("SIGN OUT" "1P LOGIN" "2P LOGIN ")  #signout 1P 2P
Combine_ID=("ID" "1P LOGIN" "2P LOGIN" "ID") # signin 1p 2p signout
Combine_PW=("PW" "PW" "PW" "PW") # signin 1p 2p signout
Player_WIN=(0 0 0) #null 1P 2P
Player_LOSE=(0 0 0) #null 1P 2P
Player_POINT=(0 0 0) #null 1P 2P
#=============공통UI==============================
	Combain_Main(){ #모든 기능의 메인함수
		menu_type=$1 #0: 메인 1:1P Login 2: 2P Login 3: sign in 4: sign out 5: Join_Lobby 6: Join_MapSelect 7: Game_Result
		menu_index=$2
		menu_num=(6 -1 -1 6 -1 2 2 1)
		menu_lim=(12 8 8 12 8 4 4 2)
		while [ true ]
		do
			clear
			menu_num[1]=-1 ; menu_num[2]=-1; menu_num[4]=-1
			case $menu_type in
				0) Main_Menu $menu_index;;
				1) Login_Out_Menu 0 $menu_index 1;;
				2) Login_Out_Menu 0 $menu_index 2;;
				3) Sign_in_Menu 0 $menu_index;;
				4) Login_Out_Menu 0 $menu_index 0;;
				5) Join_Lobby $menu_index;;
				6) Join_MapSelect $menu_index;;
				7) Game_Result $r $menu_index;;
			esac
			Input_key $menu_index ${menu_num[$menu_type]} $menu_type
			menu_index=$?
			menu_num[1]=4 ; menu_num[2]=4; menu_num[4]=4
			if [ $menu_index -ge ${menu_num[$menu_type]} ] && [ $menu_index -lt ${menu_lim[$menu_type]} ]
			then
				menu_num[1]=-1 ; menu_num[2]=-1; menu_num[4]=-1
				break
			fi
			
		done
		menu_num[1]=-1 ; menu_num[2]=-1; menu_num[4]=-1
		unset menu_type ;unset menu_num ;unset menu_lim ;
		return $menu_index
	}
	Login_Out_Menu(){ #join과 signout의 메뉴
		menu_index=$2
		player=$3 #플레이어 번호 0: signout 1: 1p 2: 2p
		figlet -c "${Login_Out_bnt_string[$player]}"
		tput cup 8 28
		if [ $menu_index = 0 ]
		then
			case $1 in
				0 | 2 ) echo -n [41m  "                     " [0m
					tput cup 8 38
					size=`expr ${#Combine_ID[$player]} / 2`
					tput cub $size
					echo -n [41m  "${Combine_ID[$player]}" [0m;;
				1 )	Combine_ID[$player]="  "
					echo -n [41m  "                     " [0m;;
			esac
		else
			echo -n [44m  "                     " [0m
			tput cup 8 38
			size=`expr ${#Combine_ID[$player]} / 2`
			tput cub $size
			echo -n [44m  "${Combine_ID[$player]}" [0m
		fi
		tput cup 10 28
		if [ $menu_index = 1 ]
		then
			case $1 in
				0 | 1 ) echo -n [41m  "                     " [0m
					tput cup 10 38
					size=`expr ${#Combine_PW[$player]} / 2`
					tput cub $size
					echo -n [41m  "${Combine_PW[$player]}" [0m;;
				2 )	Combine_PW[$player]="  "
					echo -n [41m  "                     " [0m;;
			esac
		else
			echo -n [44m  "                     " [0m
			tput cup 10 38
			size=`expr ${#Combine_PW[$player]} / 2`
			tput cub $size
			echo -n [44m  "${Combine_PW[$player]}" [0m
		fi
		tput cup 14 23
		if [ $menu_index = 2 ]
		then
			echo -n [41m  "             "
			tput cup 14 29
			size=`expr ${#Login_Out_bnt_string[$player]} / 2`
			tput cub $size
			echo -n [41m  "${Login_Out_bnt_string[$player]}" [0m
		else
			echo -n [44m  "             " [0m
			tput cup 14 29
			size=`expr ${#Login_Out_bnt_string[$player]} / 2`
			tput cub $size
			echo -n [44m  "${Login_Out_bnt_string[$player]}" [0m
		fi
		tput cup 14 41  
		if [ $menu_index = 3 ]
		then
			echo [41m  "    EXIT     " [0m
		else
			echo [44m  "    EXIT     " [0m
		fi
	}
#=============공통기능함수==============================
	Check_id_or_pw(){  # 중복체크 with File account.txt 
		keyword=$1 ; id_or_pw=$2 ; index_condition=`expr $3 - 1`
		i=0
		while read line; 
		do	# 해당 라인을 |를 기준으로 분리, f1은 그 중 첫 항목 
			if [ $i -ge $index_condition ] 
			then
				case $id_or_pw in
					1) a[$i]=`echo $line | cut -d \| -f1`;;
					2) a[$i]=`echo $line | cut -d \| -f2`;;
				esac
				if [ ${a[$i]} = $keyword ]
				then
					unset a ; unset keyword ; unset id_or_pw
					return `expr $i + 1`
				fi
			fi
			i=`expr $i + 1`
		done < account.txt
		unset i	; unset a ; unset keyword ; unset id_or_pw
		return 0
	}
	Get_WinLose(){  #파일에서 계정의 승 패 수 가져오기 
		player=$1
		i=0
		while read line; 
		do	# 해당 라인을 |를 기준으로 분리, f1은 그 중 첫 항목 
			line_id=`echo $line | cut -d \| -f1`
			if [ "${Combine_ID[$player]}" = "$line_id" ]
			then
				Player_WIN[$player]=`echo $line | cut -d \| -f3`
				Player_LOSE[$player]=`echo $line | cut -d \| -f4`
			fi
		done < account.txt
		unset i	; unset player; unset line_id
		return 0
	}
	Set_WinLose(){ #(1pw 1pl 2pw 2pl) 
		while read line; 
		do	# 해당 라인을 |를 기준으로 분리, f1은 그 중 첫 항목 
			line_id=`echo $line | cut -d \| -f1`
			if [ "${Combine_ID[1]}" = "$line_id" ]
			then
				echo "${Combine_ID[1]}|${Combine_PW[1]}|$1|$2" >> account1.txt
			elif [ "${Combine_ID[2]}" = "$line_id" ]
			then
				echo "${Combine_ID[2]}|${Combine_PW[2]}|$3|$4" >> account1.txt
			else
				echo "$line" >> account1.txt
			fi
		done < account.txt
		cp -a account1.txt account.txt 
		rm account1.txt
	}
	Abs(){ # %연산 음수값 교정 함수
		if [ $1 -ge 0 ]
		then	result=$1
		else 	v1=`expr $2 + $1`
			result=$v1
		fi
		return $result
	}
	Input_id(){ # 메뉴 0번: ID 입력함수 
		player=$1
		while [ true ]
		do
			clear
			if [ $player = 3 ]
			then 
				Sign_in_Menu 1 0 # 1: ID 입력모드 0: 본 메뉴버튼 하이라이팅
				tput cup 8 17
			else
				Login_Out_Menu 1 0 $player #1: ID 입력모드 0: 본 메뉴버튼 하이라이팅 $1:로그인player번호
				tput cup 8 30
			fi
			echo -n [41m ""
			read Combine_ID[$player]
			if [ ${Combine_ID[$player]} != "ID" ] || [ ${Combine_ID[$player]} != "" ]
			then
				echo  [0m ""
				break
			fi
		done		
	}
	Input_pw(){ # 메뉴 2번: PW 입력함수 
		while [ true ]
		do
			clear 
			if [ $player = 3 ]
			then 
				Sign_in_Menu 2 2 # 2: ID 입력모드 0: 본 메뉴버튼 하이라이팅
				tput cup 10 17
			else
				Login_Out_Menu 2 1 $player #2: ID 입력모드 0: 본 메뉴버튼 하이라이팅 $1:로그인player번호
				tput cup 10 30
			fi
			echo -n [41m ""
			read Combine_PW[$player]
			if [ ${Combine_PW[$1]} != "PW" ] || [ ${Combine_PW[$1]} != "" ]
			then
				echo  [0m ""
				break
			fi
		done		
	}
	Input_key(){ #키 입력 함수
		index=$1
		num_menu=$2  
		menu_type=$3 #0: 메인 1:1P Login 2: 2P Login 3: sign in 4: sign out 5: Join_Lobby 6: Join_MapSelect 7: Game_Result
		read -n 1 input_key_1
		if [ ! $input_key_1 ] #엔터를 입력했을 때 
	 	then
			if [ $num_menu = -1 ]
			then
				num_menu=4
			fi
			result=`expr $index + $num_menu` # 버튼index 값에 총 버튼 개수를 더해서 리턴해준다.
			unset index
			return $result
		elif [ $input_key_1 = "" ]
			then
			read -n 1 input_key_2
			if [ $input_key_2 = "[" ]
				then
				read -n 1 input_key_3
				if [ $num_menu -ge 0 ] && [ $menu_type != 5 ] && [ $menu_type != 6 ] && [ $menu_type != 7 ]
				then
					case $input_key_3 in
						"A") plma=-2 ;; #상 // 인덱스 값을 -2
						"B") plma=2 ;; #하 // 인덱스 값을 +2
						"C") plma=1 ;; #우 // 인덱스 값을 +1
						"D") plma=-1 ;; #좌 // 인덱스 값을 -1
					esac
					index=`expr \( $index + $plma \) % $num_menu`
					if [ $menu_type = 3 ] && [ $index = 3 ] && [ $num_menu = 6 ]
						then	index=`expr $index + $plma`
					fi
					unset plma
					Abs $index $num_menu
					index=$?
				elif [ $num_menu = -1 ]
					then
					case $index in
						-1) case $input_key_3 in
							"A" | "B" | "C" | "D" ) index=0;;
							esac ;;
						0) case $input_key_3 in
							"A" ) index=2;;
							"B" | "C" ) index=1;;
							"D" ) index=3;;
							esac ;;
						1) case $input_key_3 in
							"A" | "D" ) index=0;;
							"B" | "C" ) index=2;;
							esac ;;
						2) case $input_key_3 in
							"A" | "D" ) index=1;;
							"B" ) index=0;;
							"C" ) index=3;;
							esac ;;
						3) case $input_key_3 in
							"A" ) index=1;;
							"B" | "C" ) index=0;;
							"D" ) index=2;;
							esac ;;
					esac
				elif [ $menu_type = 5 ] || [ $menu_type = 6 ]
				then
					case $index in
						-1) case $input_key_3 in
							"A" | "B" | "C" | "D" ) index=0;;
							esac ;;
						0) case $input_key_3 in
							"A" | "B" ) index=0;;
							"C" | "D" ) index=1;;
							esac ;;
						1) case $input_key_3 in
							"A" | "B" ) index=1;;
							"C" | "D" ) index=0;;
							esac ;;
					esac
				elif [ $menu_type = 7 ]
				then
					case $index in
						-1 | 0 | 1) case $input_key_3 in
							"A" | "B" | "C" | "D" ) index=0;;
							esac ;;						
					esac
				fi			
			fi
			return $index
		fi
	}
#=============Login 영역==============================
	Login_Check(){ #입력한 id로 로그인이 가능한가 체크
		player=$1
		tput cup 12 18 
		if [ ${Combine_ID[$player]} = "ID" ] || [ ${Combine_PW[$player]} = "PW" ]
		then 
			echo  [31m "Please enter the ID or PW correctly" [0m
			Combine_ID[$player]="ID" ; Combine_PW[$player]="PW"
			sleep 2s # 2초간 안내문구 띄움 
			return 1
		else
			Check_id_or_pw ${Combine_ID[$player]} 1 -1 # ID(1) 중복 체크 // return 0: 안 중복 1이상: 중복
			result1=$?
			Check_id_or_pw ${Combine_PW[$player]} 2  $result1 # PW(2) 중복 체크 // return 0: 안 중복 1이상: 중복
			result2=$?
			if [ $result1 -ge 1 ] && [ $result2 -ge 1 ] && [ $result1 = $result2 ]
			then
				if [ "${Combine_ID[1]}" != "${Combine_ID[2]}" ] 
				then
					echo  [32m "${player}P LOGIN" [0m
					sleep 2s # 2초간 안내문구 띄움 
					return 0
				else
					echo  [31m "Entered the account same account of other Player. " [0m
					Combine_ID[$player]="ID" ; Combine_PW[$player]="PW"
					sleep 2s # 2초간 안내문구 띄움 
					return 1
				fi
			else
				echo  [31m "Entered the account does not exist." [0m
				Combine_ID[$player]="ID" ; Combine_PW[$player]="PW"
				sleep 2s # 2초간 안내문구 띄움 
				return 1
			fi
		fi
	}
	Player_Login(){
		player=$1
		Login_menu_index=-1; Combine_ID[$player]="ID" ; Combine_PW[$player]="PW"
		while [ true ]
		do
			Combain_Main $player $Login_menu_index
			case $? in
				4) Login_menu_index=0; Input_id $player;;
				5) Login_menu_index=1; Input_pw $player;;
				6) Login_Check $player
				if [ $? = 1 ]
				then
					Combine_ID[$player]="${player}P LOGIN"; Combine_PW[$player]="PW"
				fi 
				break ;; #login
				7) 
				if [ ${Combine_ID[$player]} = "ID" ] || [ ${Combine_PW[$player]} = "PW" ]				
					then 
					Combine_ID[$player]="${player}P LOGIN"
				fi
				break ;; 
			esac 
		done
	}
#=============Game 영역==============================
	Get_player_Point(){
		Player_POINT[1]="${#List_x1[@]}"
		Player_POINT[2]="${#List_x2[@]}"
	}
	Set_Default_Point(){
		board_index=(0 0)
		board_index[0]=25
		board_index[1]=6
		List_x1=(25 53)
		List_x2=(53 25)
		List_y1=(6 20)
		List_y2=(6 20)
		select_mode=0
		turn_num=0
		List_x=(${List_x1[@]});List_y=(${List_y1[@]})
	}
	Game_Result(){ #(winPlayer)
		clear
		Game_Result_index=$2 
		figlet -c "VICTORY"
		figlet -c "WINNER"
		size=`expr ${#Combine_ID[$1]} / 2`
		tput cuf 41
		tput cub $size ; echo "${Combine_ID[$1]}"
		Get_WinLose $1
		a="WIN: ${Player_WIN[$1]}                    LOSE: ${Player_LOSE[$1]}"
		size=`expr ${#a} / 2`
		tput cup 14 41
		tput cub $size ;echo "$a"
		a="    OK    "
		size=`expr ${#a} / 2`
		tput cup 17 41 ; tput cub $size
		if [ $Game_Result_index = 0 ]
		then
			echo [41m "$a" [0m
		else
			echo [44m "$a" [0m
		fi
		unset size a
		
		
	}
	Is_Game_End(){ #(maptype)
		point_lim=(0 64 52)
		r=0
		Get_player_Point
		if [ $[${Player_POINT[1]}+${Player_POINT[2]}] = ${point_lim[$1]} ]
		then
			r=1
		elif [ ${Player_POINT[1]} = 0 ] || [ ${Player_POINT[2]} = 0 ]
		then
			r=1
		fi
		if [ $r = 1 ]
		then
			[ ${Player_POINT[1]} -lt ${Player_POINT[2]} ] && r=2
		fi
		case $r in
			1) Set_WinLose $[${Player_WIN[1]}+1] ${Player_LOSE[1]} ${Player_WIN[2]} $[${Player_LOSE[2]}+1];;
			2) Set_WinLose ${Player_WIN[1]} $[${Player_LOSE[1]}+1] $[${Player_WIN[2]}+1] ${Player_LOSE[2]};;
		esac
		return $r
	}
	Change_Other_Point(){
		list_size=${#List_x[@]}
		x=${List_x[$list_size-1]} ; y=${List_y[$list_size-1]}
		Infection_x=($[$x-4] $x $[$x+4] $[$x-4] $[$x+4] $[$x-4] $x $[$x+4])
		Infection_y=($[$y-2] $[$y-2] $[$y-2] $y $y $[$y+2] $[$y+2] $[$y+2])
		case $turn_num in
			0) other_x=( ${List_x2[@]}) ; other_y=( ${List_y2[@]});;
			1) other_x=( ${List_x1[@]}) ; other_y=( ${List_y1[@]});;
		esac
		for k in ${!other_x[*]} ; do
			for j in ${!copyPoint_x[*]} ; do
				if [ ${Infection_x[$j]} = ${other_x[$k]} ] && [ ${Infection_y[$j]} = ${other_y[$k]} ]
				then
					remove_index=( ${remove_index[@]} $k)  #other 리스트 pop
					List_x=( ${List_x[@]} ${Infection_x[$j]});List_y=( ${List_y[@]} ${Infection_y[$j]}) #본인 리스트 push
				fi
			done
		done
		declare -i n=0
		for k in ${!other_x[*]} ; do
			m=0
			for j in ${!remove_index[*]} ; do
				if [ $k = ${remove_index[$j]} ]
				then
					m=1
				fi
			done
			if [ $m = 0 ]
			then
				temp_x[$n]=${other_x[$k]} ; temp_y[$n]=${other_y[$k]}
				n=$[$n+1]
			fi
		done
		case $turn_num in
			0) List_x2=( ${temp_x[@]}) ; List_y2=( ${temp_y[@]});;
			1) List_x1=( ${temp_x[@]}) ; List_y1=( ${temp_y[@]});;
		esac
		unset list_size x y k j n copyPoint_x copyPoint_y other_x other_y temp_x temp_y remove_index
	}
	Change_Move_Point(){
		for k in ${!List_x[*]} ; do
			if [ ${List_x[$k]} = ${select_index[0]} ] && [ ${List_y[$k]} = ${select_index[1]} ]
			then
				unset List_x[$k] List_y[$k]	
				break
			fi
		done
	}
	Turn_Player(){ #(type) 1일때 copy 2일때 move 0일때 낫띵 
		case $1 in
			1) List_x=( ${List_x[@]} ${board_index[0]});List_y=( ${List_y[@]} ${board_index[1]});;
			2) Change_Move_Point ;List_x=( ${List_x[@]} ${board_index[0]});List_y=( ${List_y[@]} ${board_index[1]}) ;;
		esac
		Change_Other_Point
		turn_num=`expr \( $turn_num + 1 \) % 2`
		case $turn_num in
			0) List_x2=( ${List_x[@]});List_y2=( ${List_y[@]});List_x=( ${List_x1[@]});List_y=( ${List_y1[@]}) ;;
			1) List_x1=( ${List_x[@]});List_y1=( ${List_y[@]});List_x=( ${List_x2[@]});List_y=( ${List_y2[@]}) ;;
		esac
	}
	Set_Select_mode(){
		select_mode=`expr \( $select_mode + 1 \) % 2`
		case $select_mode in
			0 ) unset select_index copyPoint_x copyPoint_y movePoint_x movePoint_y;;
			1 ) select_index=( ${board_index[@]})
			x=${select_index[0]}
			y=${select_index[1]}
			copyPoint_x=($[$x-4] $x $[$x+4] $[$x-4] $[$x+4] $[$x-4] $x $[$x+4])
			copyPoint_y=($[$y-2] $[$y-2] $[$y-2] $y $y $[$y+2] $[$y+2] $[$y+2])
			movePoint_x=($[$x-8] $[$x-4] $x $[$x+4] $[$x+8] $[$x-8] $[$x+8] $[$x-8] $[$x+8] $[$x-8] $[$x+8] $[$x-8] $[$x-4] $x $[$x+4] $[$x+8])
			movePoint_y=($[$y-4] $[$y-4] $[$y-4] $[$y-4] $[$y-4] $[$y-2] $[$y-2] $y $y $[$y+2] $[$y+2] $[$y+4] $[$y+4] $[$y+4] $[$y+4] $[$y+4])
			unset x y ;;
		esac
	}
	
	Display_Red_point(){
		for k in ${!List_x1[*]} ; do
			tput cup ${List_y1[$k]} ${List_x1[$k]} ; echo [41m"   "[0m
		done
	}
	Display_Green_point(){
		for k in ${!List_x2[*]} ; do
			tput cup ${List_y2[$k]} ${List_x2[$k]} ; echo [42m"   "[0m
		done
	}
	Display_blue_point(){
		i=0
		while [ ${#List_x1[@]} -gt $i ]
		do
			tput cup ${List_y1[$i]} ${List_x1[$i]} ; echo [44m"   "[0m
			i=`expr $i + 1`
		done
	}
	Is_Yellow_Point(){
		for k in 1 2 3 4 5 6
		do
			x=`expr \( $k \* 4 \) + 25`
			y1=`expr \( $k \* 2 \) + 6`
			y2=`expr 26 - $y1`
			if [ "$x" = "${board_index[0]}" ] && [ "$y1" = "${board_index[1]}" ]
			then
				return 1
			elif [ "$x" = "${board_index[0]}" ] && [ "$y2" = "${board_index[1]}" ]
			then
				return 1
			fi
		done
		return 0
	}
	Is_My_Point(){
		cnt=0
		for k in ${!List_x[*]}
		do
			if [ ${board_index[0]} = ${List_x[$k]} ] && [ ${board_index[1]} = ${List_y[$k]} ]
			then
				cnt=`expr $cnt + 1`
			fi
		done
		return $cnt
	}
	Is_Other_Point(){
		case $turn_num in
			0) x=( ${List_x2[@]}) ; y=( ${List_y2[@]}) ;;
			1) x=( ${List_x1[@]}) ; y=( ${List_y1[@]}) ;;
		esac
		cnt=0
		for k in ${!x[*]}
		do
			if [ ${board_index[0]} = ${x[$k]} ] && [ ${board_index[1]} = ${y[$k]} ]
			then
				cnt=`expr $cnt + 1`
			fi
		done
		return $cnt
	}
	Is_Copy_Point(){
		cnt=0
		for k in ${!copyPoint_x[*]}
		do
			if [ ${board_index[0]} = ${copyPoint_x[$k]} ] && [ ${board_index[1]} = ${copyPoint_y[$k]} ]
			then
				cnt=`expr $cnt + 1`
			fi
		done
		return $cnt
	}
	Is_Move_Point(){
		cnt=0
		for k in ${!movePoint_x[*]}
		do
			if [ ${board_index[0]} = ${movePoint_x[$k]} ] && [ ${board_index[1]} = ${movePoint_y[$k]} ]
			then
				cnt=`expr $cnt + 1`
			fi
		done
		return $cnt
	}
	Input_map_key(){
		board_index=$1
		map_type=$2
		read -n 1 input_key_1
		if [ ! $input_key_1 ] #엔터를 입력했을 때 
		then
			if [ $select_mode = 0 ]
			then
				Is_My_Point #return 1 일때 자기 말 임.
				if [ $? = 1 ]
				then
					Set_Select_mode
				fi
			else
				Is_Copy_Point ; cpy=$? ; Is_Move_Point ; mov=$? ; Is_Other_Point ; oth=$?
				if [ $cpy = 1 ] && [ $oth = 0 ]
				then
					case $map_type in
						1) Turn_Player 1 ; Set_Select_mode;;
						2)Is_Yellow_Point
						if [ $? = 0 ]
						then
							Turn_Player 1 ; Set_Select_mode
						fi;;
					esac
				elif [ $mov = 1 ] && [ $oth = 0 ]
				then
					case $map_type in
						1) Turn_Player 2 ; Set_Select_mode;;
						2)Is_Yellow_Point
						if [ $? = 0 ]
						then
							Turn_Player 2 ; Set_Select_mode
						fi;;
					esac
				elif [ ${board_index[0]} = ${select_index[0]} ] && [ ${board_index[1]} = ${select_index[1]} ]
				then
					case $map_type in
						1) Set_Select_mode;;
						2)Is_Yellow_Point
						if [ $? = 0 ]
						then
							Set_Select_mode
						fi;;
					esac
				fi
					
			fi
		elif [ $input_key_1 = "" ]
			then
			read -n 1 input_key_2
			if [ $input_key_2 = "[" ]
				then
				read -n 1 input_key_3
				[ $select_mode = 1 ] && temp_index=(${board_index[@]})
				case $input_key_3 in
					"A") board_index[1]=`expr ${board_index[1]} - 2`;; #상 // 인덱스 값을 -2
					"B") board_index[1]=`expr ${board_index[1]} + 2`;; #하 // 인덱스 값을 +2
					"C") board_index[0]=`expr ${board_index[0]} + 4`;;  #우 // 인덱스 값을 +4
					"D") board_index[0]=`expr ${board_index[0]} - 4`;;  #좌 // 인덱스 값을 -4
				esac 
				if [ $select_mode = 1 ]
				then
					Is_Copy_Point ; cpy=$? ; Is_Move_Point ; mov=$? 
					if [ ${board_index[0]} = ${select_index[0]} ] && [ ${board_index[1]} = ${select_index[1]} ]
					then
						board_index=(${select_index[@]})
					else
						if [ $cpy = 0 ] && [ $mov = 0 ]
						then
							board_index=(${temp_index[@]})
						fi
					fi					
				fi
				if [ ${board_index[1]} = 4 ]
				then
					board_index[1]=6
				elif [ ${board_index[1]} = 22 ]	
				then
					board_index[1]=20
				fi
				if [ ${board_index[0]} = 57 ]	
				then
					board_index[0]=53
				elif [ ${board_index[0]} = 21 ]
				then
					board_index[0]=25
				fi
			fi
		fi
	}
	Map_board(){
		map_type=$1
		clear
		figlet -c "ATAXX"
		tput cup 5 24; echo "┌───┬───┬───┬───┬───┬───┬───┬───┐"
		for k in 1 2 3 4 5 6 7
		do
			tput cuf 24;echo "│   │   │   │   │   │   │   │   │"
			tput cuf 24;echo "├───┼───┼───┼───┼───┼───┼───┼───┤"
		done
		tput cuf 24; echo "│   │   │   │   │   │   │   │   │"
		tput cuf 24; echo "└───┴───┴───┴───┴───┴───┴───┴───┘"
		Get_player_Point
		light=('[0m' '[0m')
		[ $turn_num = 0 ] && light[0]='[41m' || light[1]='[42m'
		tput cuf 23; echo -n "${light[0]}  [0m1P: ${Player_POINT[1]}"
		tput cuf 18; echo "${light[1]}  [0m2P: ${Player_POINT[2]}"
		if [ $map_type = 2 ]
		then
			for k in 1 2 3 4 5 6
			do
				x=`expr \( $k \* 4 \) + 25`
				y1=`expr \( $k \* 2 \) + 6`
				y2=`expr 26 - $y1`
				tput cup $y1 $x ; echo [43m"   "[0m
				tput cup $y2 $x ; echo [43m"   "[0m
			done
		fi
		unset x y1 y2 light
	}	
	Map_Main(){
		map_type=$1
		Set_Default_Point
		while [ true ]
		do
			clear
			Is_Game_End $map_type
			[ $? -ge 1 ] && break
			Map_board $map_type
			if [ $select_mode = 1 ]
			then
				tput cup ${select_index[1]} $[${select_index[0]}-1] ; echo [44m"     "[0m
			fi
			Display_Red_point
			Display_Green_point
			tput cup ${board_index[1]} ${board_index[0]} ; echo [47m"   "[0m
			Input_map_key $board_index $map_type			
		done
		Game_Result_index=-1
		while [ true ]
		do
			Combain_Main 7 $Game_Result_index
			case $? in
				1)Join_flow;;
			esac 
		done ;
		return $board_index
	}
#=============Join 영역==============================
	Join_Lobby(){ # 게임 시작 전 로비
		Lobby_menu_index=$1
		Get_WinLose 1 ; Get_WinLose 2
		clear
		tput cup 0 0
		figlet -c "ATAXX"
		tput cup 5 0
		figlet -c "LOBBY"
		tput cup 10 0
		figlet -c " 1P                           2P"
		tput cup 16 10; echo "ID: ${Combine_ID[1]}"
		tput cup 16 46; echo "ID: ${Combine_ID[2]}"
		tput cup 17 10; echo "WIN: ${Player_WIN[1]}"
		tput cup 17 46; echo "WIN: ${Player_WIN[2]}"
		tput cup 18 10; echo "LOSE: ${Player_LOSE[1]}"
		tput cup 18 46; echo "LOSE: ${Player_LOSE[2]}"
		tput cup 22 24
		if [ $Lobby_menu_index = 0 ]
		then
			echo [41m "  START   " [0m
		else
			echo [44m "  START   " [0m
		fi
		tput cup 22 42
		if [ $Lobby_menu_index = 1 ]
		then
			echo [41m "   EXIT   " [0m
		else
			echo [44m "   EXIT   " [0m
		fi		
	}
	Join_MapSelect(){
		Lobby_menu_index=$1
		clear
		tput cup 0 0
		figlet -c "ATAXX"
		tput cup 5 0
		figlet -c "MAPSELECT"
		tput cup 10 12 ; echo "┌─┬─┬─┬─┬─┬─┬─┬─┐"
		for k in 1 2 3 4 5 6 7
		do
			tput cuf 12;echo "├─┼─┼─┼─┼─┼─┼─┼─┤"
		done
		
		tput cuf 12;echo "└─┴─┴─┴─┴─┴─┴─┴─┘"
		undwht='[4;37m' # White
		yellow='[43m'
		white='[0m'
		tput cup 10 50 ;echo "$undwht                 $white"
		tput cuf 50;echo "$undwht│ │ │ │ │ │ │ │ │$white"
		tput cuf 50;echo "$undwht│ │$yellow $white$undwht│ │ │ │ │$yellow $white$undwht│ │$white"
		tput cuf 50;echo "$undwht│ │ │$yellow $white$undwht│ │ │$yellow $white$undwht│ │ │$white"
		tput cuf 50;echo "$undwht│ │ │ │$yellow $white$undwht│$yellow $white$undwht│ │ │ │$white"
		tput cuf 50;echo "$undwht│ │ │ │$yellow $white$undwht│$yellow $white$undwht│ │ │ │$white"
		tput cuf 50;echo "$undwht│ │ │$yellow $white$undwht│ │ │$yellow $white$undwht│ │ │$white"
		tput cuf 50;echo "$undwht│ │$yellow $white$undwht│ │ │ │ │$yellow $white$undwht│ │$white"
		tput cuf 50;echo "$undwht│ │ │ │ │ │ │ │ │$white"
		tput cuf 50;echo "▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔"
		
		tput cup 20 15
		if [ "$Lobby_menu_index" = "0" ]
		then
			echo [41m "   MAP1   " [0m
		else
			echo [44m "   MAP1   " [0m
		fi
		tput cup 20 53
		if [ "$Lobby_menu_index" = "1" ]
		then
			echo -n [41m "   MAP2   " [0m
		else
			echo -n [44m "   MAP2   " [0m
		fi
	}
	Join_flow(){
		while [ true ]
		do
			main_menu_index=4; Join_menu_index=-1
			while [ true ]
			do
				Combain_Main 5 $Join_menu_index
				case $? in
					2) main_menu_index=4; Join_menu_index=-1
						while [ true ]
						do
							Combain_Main 6 $Join_menu_index
							case $? in
								2)
								while [ true ]
								do
									Map_Main 1
								done ;; #start
								3) 
								while [ true ]
								do
									Map_Main 2
								done ;; #start

							esac 
						done ;; #start
					3) main ;; 
				esac 
			done
		done 
	}	
#=============Sign in 영역==============================
	Sign_in_Duplicate(){ # 메뉴 1번: 아이디 중복 체크 함수
		clear
		Sign_in_Menu 0 1 # 0: 일반모드 1: 본 메뉴버튼 하이라이팅 
		tput cup 10 41 
		if [ ${Combine_ID[3]} = "ID" ]
		then 
			echo  [31m "Please enter the ID correctly" [0m
		else
			Check_id_or_pw ${Combine_ID[3]} 1 -1 # 아이디(1) 중복 체크 // return 0: 안 중복 1 이상: 중복 
			if [ $? -ge 1 ]
			then
				echo  [31m "Entered the ID is duplicated." [0m
				Combine_ID[3]="ID"
			else
				echo  [32m "Entered the ID is available." [0m
			fi
		fi
		sleep 2s # 2초간 안내문구 띄움 
	}
	Sign_in_Save_input(){ # 메뉴 4번: 계정 저장함수
		clear
		Sign_in_Menu 0 4 # 0: 일반모드 4: 본 메뉴버튼 하이라이팅
		Check_id_or_pw ${Combine_ID[3]} 1 -1 # 아이디(1) 중복 체크 // return 0: 안 중복 1 이상: 중복 
		if [ $? -gt 0 ]
			then 
			tput cup 10 41
			echo  [31m "Entered the ID is duplicated."[0m
			Combine_ID[3]="ID" ; Combine_PW[3]="PW"
		elif [ ${Combine_ID[3]} = "ID" ] || [ $Combine_PW[3] = "PW" ]
			then
			tput cup 10 41
			echo  [31m "Please enter the ID or PW correctly"[0m
			Combine_ID[3]="ID" ; Combine_PW[3]="PW"
		else
			echo "${Combine_ID[3]}|${Combine_PW[3]}|0|0" >> account.txt
			echo  [32m "Entered the Account saved to file." [0m
			Combine_ID[3]="ID" ; Combine_PW[3]="PW"
		fi
		sleep 2s
	}
	Sign_in_Menu(){ # Signin 메뉴 출력함수 
		Sign_in_menu_index=$2
		figlet -c "S I G N   I N"
		tput cup 8 15
		if [ $Sign_in_menu_index = 0 ]
		then
			case $1 in
				0 | 2 ) 
				echo -n [41m  "                     " [0m
				tput cup 8 25
				size=`expr ${#Combine_ID[3]} / 2`
				tput cub $size
				echo -n [41m  "${Combine_ID[3]}" [0m;;
				1 )
				Combine_ID[3]="  "
				echo -n [41m  "                     " [0m;;
			esac
		else
			echo -n [44m  "                     " [0m
			tput cup 8 25
			size=`expr ${#Combine_ID[3]} / 2`
			tput cub $size
			echo -n [44m  "${Combine_ID[3]}" [0m
		fi
		tput cup 8 41
		if [ $Sign_in_menu_index = 1 ]
		then	echo  [41m  "  Duplicate check   " [0m
		else
			echo  [44m  "  Duplicate check   " [0m
		fi
		tput cup 10 15
		if [ $Sign_in_menu_index = 2 ]
		then
			case $1 in
				0 | 1 ) 
				echo -n [41m  "                     " [0m
				tput cup 10 25
				size=`expr ${#Combine_PW[3]} / 2`
				tput cub $size
				echo -n [41m  "${Combine_PW[3]}" [0m;;
				2 )
				Combine_PW[3]="  "
				echo -n [41m  "                     " [0m;; 
			esac
		else
			echo -n [44m  "                     " [0m
			tput cup 10 25
			size=`expr ${#Combine_PW[3]} / 2`
			tput cub $size
			echo -n [44m  "${Combine_PW[3]}" [0m
		fi
		tput cup 14 24
		if [ $Sign_in_menu_index = 4 ]
		then	echo -n [41m  "  SIGN IN   " [0m
		else
			echo -n [44m  "  SIGN IN   " [0m
		fi
		tput cup 14 41
		if [ $Sign_in_menu_index = 5 ]
		then	echo [41m  "   EXIT     " [0m
		else
			echo [44m  "   EXIT     " [0m
		fi
	}
#=============Sign out 영역==============================
	Sign_out_Del_account(){
		clear
		Login_Out_Menu 0 2 0 # 0: 일반모드 2: 본 메뉴버튼 하이라이팅  0: sign out의 메뉴
		tput cup 12 18 
		if [ ${Combine_ID[0]} = "ID" ] || [ ${Combine_PW[0]} = "PW" ]
		then 
			echo  [31m "Please enter the ID or PW correctly" [0m
		else
			Check_id_or_pw ${Combine_ID[0]} 1 -1 # ID(1) 중복 체크 // return 0: 안 중복 1이상: 중복
			result1=$?
			Check_id_or_pw ${Combine_PW[0]} 2 $result1 # PW(2) 중복 체크 // return s: 안 중복 1이상: 중복
			result2=$?
			if [ $result1 -ge 1 ] && [ $result2 -ge 1 ] && [ $result1 = $result2 ] #ID PW 둘 다 저장된 계정과 일치할 때 
			then
				Sign_out__Del_account_file $result1
				echo  [32m "Entered the ID or PW  was deleted." [0m
				Combine_ID[3]="ID" ; Combine_PW[3]="PW" ; 
				
			else
				echo  [31m "Entered the account does not exist." [0m
			fi
		fi
		Combine_ID[0]="ID" ; Combine_PW[0]="PW"
		sleep 2s # 2초간 안내문구 띄움 
	}
	Sign_out__Del_account_file(){
		touch account1.txt
		del_index=`expr $1 - 1`
		i=0
		while read line
		do
			if [ $i != $del_index ]
			then
				echo "$line" >> account1.txt
			fi
			i=`expr $i + 1`
		done < account.txt
		cp -a account1.txt account.txt 
		rm account1.txt
	}
#=============main 영역==============================
	Main_Menu(){ #메인 메뉴 의 메뉴 출력 함수
		main_menu_index=$1
		figlet -c "  S O S I L 1" ; figlet -c "  A T A X X"
		tput cup 12 38
		echo "2014726048 KIM JeongGyu"
		tput cup 15 22
		size=`expr ${#Combine_ID[1]} / 2`
		if [ $main_menu_index = 0 ]
		then	echo -n [41m  "             " [0m
			tput cup 15 28
			tput cub $size
			echo -n [41m  "${Combine_ID[1]}" [0m
		else
			echo -n [44m  "             " [0m
			tput cup 15 28
			tput cub $size
			echo -n [44m  "${Combine_ID[1]}" [0m
		fi
		tput cup 15 44 
		if [ $main_menu_index = 1 ]
		then	echo -n [41m  "  SIGN I N   " [0m
		else
			echo -n [44m  "  SIGN I N   " [0m
		fi
		echo [0m  " "
		tput cup 17 22
		size=`expr ${#Combine_ID[2]} / 2`
		if [ $main_menu_index = 2 ]
		then	echo -n [41m  "             " [0m
			tput cup 17 28
			tput cub $size
			echo -n [41m  "${Combine_ID[2]}" [0m
		else
			echo -n [44m  "             " [0m
			tput cup 17 28
			tput cub $size
			echo -n [44m  "${Combine_ID[2]}" [0m
		fi
		tput cup 17 44
		if [ $main_menu_index = 3 ]
		then	echo -n [41m  "  SIGN OUT   " [0m
		else
			echo -n [44m  "  SIGN OUT   " [0m
		fi
		tput cup 19 28
		if [ $main_menu_index = 4 ]
		then	echo -n [41m  "  JOIN   " [0m
		else
			echo -n [44m  "  JOIN   " [0m
		fi
		tput cup 19 42
		if [ $main_menu_index = 5 ]
		then	echo -n [41m  "  EXIT   " [0m
		else
			echo -n [44m  "  EXIT   " [0m
		fi
	}
	main(){
		main_menu_index=-1
		while [ true ]
		do
			Combain_Main 0 $main_menu_index
			case $? in
				6) main_menu_index=0 ; Player_Login 1;;
				7) main_menu_index=1 ; Sign_in_menu_index=-1
				while [ true ]
				do
					Combain_Main 3 $Sign_in_menu_index
					case $? in
						6) Input_id 3;;
						7) Sign_in_Duplicate;;
						8) Input_pw 3;;
						10) unset Sign_in_menu_index
						Sign_in_Save_input
						break ;;
						11) unset Sign_in_menu_index; Combine_ID[3]="ID"; Combine_PW[3]="PW" ; break;;
					esac 
				done ;;
				8) main_menu_index=2 ; Player_Login 2;;
				9) main_menu_index=3 ; Sign_out_menu_index=-1
				while [ true ]
				do
					Combain_Main 4 $Sign_out_menu_index		
					case $? in
						4) Sign_out_menu_index=0; Input_id 0;;
						5) Sign_out_menu_index=1; Input_pw 0;;
						6) unset Sign_out_menu_index
						Sign_out_Del_account
						break ;;
						7) unset Sign_out_menu_index ; Combine_ID[0]="ID"; Combine_PW[0]="PW" ;
						break ;;
					esac 
				done ;;
				10) main_menu_index=4
				if [ "${Combine_ID[1]}" = "1P LOGIN" ] || [ "${Combine_ID[2]}" = "2P LOGIN" ] || [ "${Combine_PW[1]}" = "PW" ] || [ "${Combine_PW[2]}" = "PW" ]
				then
					echo [31m"Please login to your account."[0m ; sleep 2s
					continue
				fi 
				Join_flow ;;
				11) unset main_menu_index ; echo "Exit the program."; exit 0 ;;
			esac
		done
	}
#==========================================================================
main
