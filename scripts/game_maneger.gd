extends Node

######################### Játékhoz fontos adatok
@export var Guest=false

@export var restartSceene=""
@export var cutSceene=false
@export var zoom=0.2
@export var BetoltesVideo=false
@export var courrentsave=0
@export var savename=""
@export var message=""
@export var BossMaxHP=0
@export var BossHP=0
@export var BossName=""
@export var dialog=false
@export var GamePoused=false
@export var loggedin=false
@export var WhereBack=""
@export var NextScene=""
@export var LoadingScene="res://scenes/Other/loading_screen.tscn"

@export var szerverIp="https://nodejs310.dszcbaross.edu.hu" 
#Sajáthoz ne irj semmit is ugy automatikusan " http://127.0.0.1:6000 " lesz
#Mónika http://192.168.10.18:6500
#Szerver https://nodejs310.dszcbaross.edu.hu

######################### Beállitások

@export var volume=0
@export var VSync=false
@export var FullScreen=false

######################### Játékos adatok
@export var token=""

@export var username=""
@export var uid=0

@export var localachivements=[]
@export var achivements=[]
@export var earenedachivements=[]
######################### Játékos mentési adatai
@export var BestLevel=0

@export var TalkedNpc=0
@export var KilledEntity=0
@export var DieCounts=0

func mentes():
	var file = FileAccess.open(savename+"/stat.dat", FileAccess.WRITE)
	var data = {
			"TalkedNpc":TalkedNpc,
			"KilledEntity":KilledEntity,
			"DieCounts":DieCounts
		}
	file.store_string(JSON.stringify(data))
	file.close()
