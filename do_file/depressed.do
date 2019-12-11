clear
set more off
set scrollbufsize 2048000
capture log close

/*set directory*/
	global datadir "C:\Users\wangh\Desktop\师范生报告\第六章抑郁数据处理\rawdata"
	global workingdir "C:\Users\wangh\Desktop\师范生报告\第六章抑郁数据处理\working"
	global savedir "C:\Users\wangh\Desktop\师范生报告\第六章抑郁数据处理\save"
	cd "$savedir"

*修改
use "$datadir/2016ji student dataset.dta",clear

keep if regexm(学号, "^[4][1][6][0-2][0-9][0-9][0-9][0-9]$" ) == 1 & stu_b_16_stuid != "" & stu_b_16_stuname != ""
rename 学号 stuid
，

***********数据处理******************
*是否免费师范生
tab stu_b_16_47,m
*专业
tab stu_b_16_stumajor,m
*出生年份
tab stu_b_16_1,m
tab stu_b_16_1,m
*性别
tab stu_b_16_3,m
tab stu_b_16_3,m
*民族
tab stu_b_16_4,m
tab stu_b_16_4a,m
*户籍 （5个没有户口）
tab stu_b_16_5,m
tab stu_b_16_5,m
*是否来自城市
tab stu_b_16_26,m
tab stu_b_16_26a,m
*父亲文化程度 （48个不知道，111个没填）
tab stu_b_16_19_101,m
*母亲文化程度
tab stu_b_16_19_102,m
*父亲职业 （353个其他）
tab stu_b_16_21_101,m
*母亲职业 （345个其他）
tab stu_b_16_21_102,m
*是否独生子女3456
tab stu_b_16_11_103,m
*是否能上网
tab stu_b_16_27,m
tab stu_b_16_27,m
*冰箱
tab stu_b_16_28a,m
tab stu_b_16_28a,m
*微波炉
tab stu_b_16_28b,m
*电脑
tab stu_b_16_28c,m
*空调
tab stu_b_16_28d,m
*小汽车
tab stu_b_16_28e,m
*洗衣机
tab stu_b_16_28f,m
*洗碗机
tab stu_b_16_28g,m
*吸尘器
tab stu_b_16_28h,m
tab stu_b_16_28h,m
*是否第一志愿
tab stu_b_16_43,m
replace stu_b_16_43=0 if stu_b_16_43==2
rename stu_b_16_43 zhiyuan

**SCL-90抑郁分量表
*5	对异性的兴趣减退
tab stu_b_16_5_3,m
tab stu_b_16_5_3,m	
*14	感到自己的精力下降，活动减慢
tab stu_b_16_14_3,m
*15	想结束自己的生命
tab stu_b_16_15_3,m
*20	容易哭泣
tab stu_b_16_20_3,m
*22	感到受骗，中了圈套或有人想抓住您
tab stu_b_16_22_3,m
tab stu_b_16_22_3,m
*26	经常责怪自己
tab stu_b_16_26_3,m
*29	感到孤独
tab stu_b_16_29_3,m
*30	感到苦闷
tab stu_b_16_30_3,m
*31	过分担忧
tab stu_b_16_31_3,m
tab stu_b_16_31_3,m
*32	对事物不感兴趣
tab stu_b_16_32_3,m
*54	感到前途没有希望
tab stu_b_16_54_3,m
*71	感到任何事情都很困难
tab stu_b_16_71_3,m
tab stu_b_16_71_3,m
*79	感到自己没有什么价值
tab stu_b_16_79_3,m

//drop
drop if stu_b_16_1 == ".o" //drop1个
drop if stu_b_16_3 == . //drop9个
drop if stu_b_16_5 == 3

drop if stu_b_16_19_101 == . & stu_b_16_19_102 == . //drop11个
drop if stu_b_16_19_101 == . & stu_b_16_19_102 == .n //drop0个
drop if stu_b_16_19_101 == . & stu_b_16_19_102 == 16 //drop0个
drop if stu_b_16_19_101 == 16 & stu_b_16_19_102 == . //drop1个
drop if stu_b_16_19_101 == 16 & stu_b_16_19_102 == .n //drop0个
drop if stu_b_16_19_101 == 16 & stu_b_16_19_102 == 16 //drop29个

drop if stu_b_16_21_101 == . & stu_b_16_21_102 == . //drop0个

drop if stu_b_16_27 == . //drop11个
drop if stu_b_16_28a == . //drop1个

drop if stu_b_16_28h == . //drop2个

drop if stu_b_16_5_3 == . //drop1个
drop if stu_b_16_22_3 == . //drop2个
drop if stu_b_16_31_3 == . //drop3个
drop if stu_b_16_71_3 == . //drop1个


*************生成自变量*****************
*是否免费师范生 fnormalstu
gen fnormalstu = .
replace fnormalstu = 1 if stu_b_16_47 == 1
replace fnormalstu = 0 if stu_b_16_47 == 2 | stu_b_16_47 == 3
tab fnormalstu,m

*1=自我主导的公费师范生报考生 0=非自我主导的公费师范生报考生
g stu_selfmotiv=2-stu_b_16_52
tab stu_selfmotiv,m

*************生成因变量******************
*抑郁得分  depressed
egen depressed = rowtotal(stu_b_16_5_3 stu_b_16_14_3 stu_b_16_15_3 stu_b_16_20_3 stu_b_16_22_3 stu_b_16_26_3 stu_b_16_29_3 stu_b_16_30_3 stu_b_16_31_3 stu_b_16_32_3 stu_b_16_54_3 stu_b_16_71_3 stu_b_16_79_3)
egen mdepressed = rowmean(stu_b_16_5_3 stu_b_16_14_3 stu_b_16_15_3 stu_b_16_20_3 stu_b_16_22_3 stu_b_16_26_3 stu_b_16_29_3 stu_b_16_30_3 stu_b_16_31_3 stu_b_16_32_3 stu_b_16_54_3 stu_b_16_71_3 stu_b_16_79_3)
//depressed>26, mdepressed>2检出抑郁

**标准化期末英语成绩 sd_term_exam_总评成绩 
egen sd_term_exam_总评成绩 = std(term_exam_总评成绩)


*************生成控制变量**************
**专业  major
*0理工学，1社会科学
tab stu_b_16_stumajor,m
gen major = .
replace major = 0 if stu_b_16_stumajor ==  "化学" | stu_b_16_stumajor == "化学类" | stu_b_16_stumajor == "化学（免费师范生）" | stu_b_16_stumajor == "地理科学" | stu_b_16_stumajor == "地理科学类" | stu_b_16_stumajor == "数学与应用数学" | stu_b_16_stumajor == "数学类" | stu_b_16_stumajor == "物理学" | stu_b_16_stumajor == "物理学系类" | stu_b_16_stumajor == "计算机科学与技术" | stu_b_16_stumajor == "计算机类" | stu_b_16_stumajor == "食品科学与工程类" | stu_b_16_stumajor ==  "生物科学" | stu_b_16_stumajor == "生物科学类"   
replace major = 1 if stu_b_16_stumajor == "中国语言文学" | stu_b_16_stumajor == "体育教育" | stu_b_16_stumajor == "俄语" | stu_b_16_stumajor == "公共事业管理" | stu_b_16_stumajor == "公共事业管理（教育管理方向）" | stu_b_16_stumajor == "公共事业管理（教育管理）" | stu_b_16_stumajor == "历史学" | stu_b_16_stumajor == "历史学类" | stu_b_16_stumajor == "哲学" | stu_b_16_stumajor == "外国语言文学类" | stu_b_16_stumajor == "学前教育" | stu_b_16_stumajor == "工商管理类" | stu_b_16_stumajor == "广播电视编导" | stu_b_16_stumajor == "心理学类" | stu_b_16_stumajor == "思想政治教育" | stu_b_16_stumajor == "思想政治教育(创新实验班)" | stu_b_16_stumajor == "播音与主持艺术" | stu_b_16_stumajor == "教育技术学" | stu_b_16_stumajor == "新闻传播学类" | stu_b_16_stumajor == "旅游管理" | stu_b_16_stumajor == "日语" | stu_b_16_stumajor == "汉语国际教育" | stu_b_16_stumajor == "汉语言文学" | stu_b_16_stumajor == "法学" | stu_b_16_stumajor == "社会学" | stu_b_16_stumajor == "经济学类" | stu_b_16_stumajor == "美术学" | stu_b_16_stumajor == "美术学类" | stu_b_16_stumajor == "舞蹈学" | stu_b_16_stumajor == "舞蹈学（非师范）" | stu_b_16_stumajor == "英语(免师)" | stu_b_16_stumajor == "行政管理" | stu_b_16_stumajor == "音乐学" | stu_b_16_stumajor == "音乐学（师范）" | stu_b_16_stumajor == "音乐学（非师范）" | stu_b_16_stumajor == "音乐学（音乐教育免生）" | stu_b_16_stumajor == "音乐表演" | stu_b_16_stumajor == "音乐表演（钢琴）" | stu_b_16_stumajor == "运动训练"  
tab major,m
label define af 0 "理工科"  1 "社会科学"
label values major af
tab major,m

**年龄  age
tab stu_b_16_1,m
destring stu_b_16_1,replace
gen age = 2016 - stu_b_16_1
tab age,m 
drop if age == 15 | age == 23 | age == 25 | age == 26 | age == 27
tab age,m 
//年龄分层(age1)
gen age1=.
	replace age1=1 if age <= 17
	replace age1=2 if age == 18
	replace age1=1 if age == 19
	replace age1=2 if age >= 20
	
//将年龄分为18岁以上=1和18岁及以下=0（age2）
gen age2 = .
replace age2 = 0 if age == 16 | age == 17 | age == 18
replace age2 = 1 if age == 19 | age == 20 | age == 21 | age == 22
tab age2,m

**性别  gender
tab stu_b_16_3,m
gen gender = .
replace gender = 0 if stu_b_16_3 == 2
replace gender = 1 if stu_b_16_3 == 1
label define ag 1 "男"  0 "女"
label values gender ag
tab gender,m

**民族  nation
tab stu_b_16_4,m
tab stu_b_16_4a,m
gen nation = .
replace nation = 0 if stu_b_16_4 == 1
replace nation = 1 if stu_b_16_4 == 2 | stu_b_16_4 == 3 | stu_b_16_4 == 4 | stu_b_16_4 == 5 | stu_b_16_4 == 6 | stu_b_16_4 == 7
tab nation,m
label define ab 1 "少数民族"  0 "汉族"
label values nation ab
tab nation,m

**是否独生子女  onlychild
tab stu_b_16_11_103,m
gen onlychild = .
replace onlychild = 1 if stu_b_16_11_103 == "." | stu_b_16_11_103 == "1" | stu_b_16_11_103 == "7" | stu_b_16_11_103 == "8" | stu_b_16_11_103 == "9"
replace onlychild = 0 if stu_b_16_11_103 == "3" | stu_b_16_11_103 == "3,残疾" | stu_b_16_11_103 == "3、去世" | stu_b_16_11_103 == "4" | stu_b_16_11_103 == "5" | stu_b_16_11_103 == "6" | stu_b_16_11_103 == "6,有健康问题" | stu_b_16_11_103 == "姐妹"
tab onlychild,m
label define bb 1 "独生子女"  0 "非独生子女" 
label values onlychild bb
tab onlychild,m

**户籍  hukou
tab stu_b_16_5,m
gen hukou = .
replace hukou = 0 if stu_b_16_5 == 2
replace hukou = 1 if stu_b_16_5 == 1
tab hukou,m
label define ac 1 "农村户口"  0 "城镇户口"
label values hukou ac
tab hukou,m

**家庭财产资源  sd_famasset
*PISA:书桌，自己房间，安静学习场所，电脑，教育软件，网络，计算器，经典文学作品，诗词集，艺术品，教辅读物，字典，洗碗机，DVD&VCD，1，2,3
*问卷：联网，冰箱，微波炉，电脑，空调，小汽车，洗衣机，洗碗机，吸尘器
recode stu_b_16_27 (2=0)
recode stu_b_16_28a (2=0)
recode stu_b_16_28b (2=0)
recode stu_b_16_28c (2=0)
recode stu_b_16_28d (2=0)
recode stu_b_16_28e (2=0)
recode stu_b_16_28f (2=0)
recode stu_b_16_28g (2=0)
recode stu_b_16_28h (2=0)
egen famasset = rowtotal(stu_b_16_27-stu_b_16_28h)
egen sd_famasset = std(famasset)
tab sd_famasset,m


**父母职业  sd_parentcareer
*参考：1失业待业退休人员2农民临时工3工人、个体、商业服务业一般工作人员4专业技术人员5管理人员6国家干部公务员
*问卷：1在校生2务农3只做家务4经商5给人打工6工人7老师8政府官员9其他
*处理：2→2,3→1，4→5，56→3,7→4,8→6
*父亲职业 129个.
tab stu_b_16_21_101,m
gen facareer = .
replace facareer = 1 if stu_b_16_21_101 == 3
replace facareer = 2 if stu_b_16_21_101 == 2
replace facareer = 3 if stu_b_16_21_101 == 5 | stu_b_16_21_101 == 6
replace facareer = 4 if stu_b_16_21_101 == 7
replace facareer = 5 if stu_b_16_21_101 == 4
replace facareer = 6 if stu_b_16_21_101 == 8
tab facareer,m
tab stu_b_16_21a_101
replace facareer = 1 if stu_b_16_21a_101 == "下岗" | stu_b_16_21a_101 == "下岗职工待业" | stu_b_16_21a_101 == "丧失劳动能力" | stu_b_16_21a_101 == "因病休养" | stu_b_16_21a_101 == "因病在家" | stu_b_16_21a_101 == "失业" | stu_b_16_21a_101 == "待业" | stu_b_16_21a_101 == "待业在家" | stu_b_16_21a_101 == "患病" | stu_b_16_21a_101 == "无" | stu_b_16_21a_101 == "无业" | stu_b_16_21a_101 == "服刑" | stu_b_16_21a_101 == "残疾" | stu_b_16_21a_101 == "残疾抱病在家" | stu_b_16_21a_101 == "病退" | stu_b_16_21a_101 == "退休"
replace facareer = 2 if stu_b_16_21a_101 == "养殖" | stu_b_16_21a_101 == "散工" | stu_b_16_21a_101 == "渔业养殖" | stu_b_16_21a_101 == "牧业"
replace facareer = 3 if stu_b_16_21a_101 == "个人包揽工程" | stu_b_16_21a_101 == "个体" | stu_b_16_21a_101 == "个体商户" | stu_b_16_21a_101 == "个体户" | stu_b_16_21a_101 == "个体金融" | stu_b_16_21a_101 == "保安"  | stu_b_16_21a_101 == "出租司机" | stu_b_16_21a_101 == "出租房屋" | stu_b_16_21a_101 == "出租车司机" | stu_b_16_21a_101 == "司机" | stu_b_16_21a_101 == "司机自己开车" | stu_b_16_21a_101 == "商贩" | stu_b_16_21a_101 == "小商贩" | stu_b_16_21a_101 == "服务行业" | stu_b_16_21a_101 == "机??司机" | stu_b_16_21a_101 == "社区清理卫生" | stu_b_16_21a_101 == "自由" | stu_b_16_21a_101 == "自由职业" | stu_b_16_21a_101 == "自营" | stu_b_16_21a_101 == "货运"
replace facareer = 4 if stu_b_16_21a_101 == "乐队乐手" | stu_b_16_21a_101 == "企业会计" | stu_b_16_21a_101 == "企业单位" | stu_b_16_21a_101 == "企业员工" | stu_b_16_21a_101 == "企业职工" | stu_b_16_21a_101 == "会计" | stu_b_16_21a_101 == "会计师" | stu_b_16_21a_101 == "信贷员" | stu_b_16_21a_101 == "公司职员" | stu_b_16_21a_101 == "出纳" | stu_b_16_21a_101 == "制药工人" | stu_b_16_21a_101 == "包钢职工" | stu_b_16_21a_101 == "医护人员" | stu_b_16_21a_101 == "医生" | stu_b_16_21a_101 == "医院医生" | stu_b_16_21a_101 == "单位职员" | stu_b_16_21a_101 == "卫生检验" | stu_b_16_21a_101 == "员工" | stu_b_16_21a_101 == "在职员工" | stu_b_16_21a_101 == "安全员" | stu_b_16_21a_101 == "工司职员" | stu_b_16_21a_101 == "工程师" | stu_b_16_21a_101 == "律师" | stu_b_16_21a_101 == "技术人员" | stu_b_16_21a_101 == "证券分析师" | stu_b_16_21a_101 == "文书" | stu_b_16_21a_101 == "文博人员" | stu_b_16_21a_101 == "普通员工" | stu_b_16_21a_101 == "普通职员" | stu_b_16_21a_101 == "机场人员" | stu_b_16_21a_101 == "农业工程师" | stu_b_16_21a_101 == "检疫员" | stu_b_16_21a_101 == "检验师" | stu_b_16_21a_101 == "水电工程师" | stu_b_16_21a_101 == "演奏员" | stu_b_16_21a_101 == "研究院" | stu_b_16_21a_101 == "研究院" | stu_b_16_21a_101 == "私企职员" | stu_b_16_21a_101 == "科员" | stu_b_16_21a_101 == "编辑" | stu_b_16_21a_101 == "职业经理人" | stu_b_16_21a_101 == "职员" | stu_b_16_21a_101 == "职工" | stu_b_16_21a_101 == "药业公司上班" | stu_b_16_21a_101 == "观测员" | stu_b_16_21a_101 == "记者" | stu_b_16_21a_101 == "讲师" | stu_b_16_21a_101 == "试飞员" | stu_b_16_21a_101 == "金融从业员" | stu_b_16_21a_101 == "银行" | stu_b_16_21a_101 == "银行员工" | stu_b_16_21a_101 == "银行职员" | stu_b_16_21a_101 == "驾校教练员" | stu_b_16_21a_101 == "高级工程师" | stu_b_16_21a_101 == "畜牧师"
replace facareer = 5 if stu_b_16_21a_101 == "主任" | stu_b_16_21a_101 == "主管" | stu_b_16_21a_101 == "企业主" | stu_b_16_21a_101 == "公司领导" | stu_b_16_21a_101 == "办公室主任" | stu_b_16_21a_101 == "工程监理" | stu_b_16_21a_101 == "开厂" | stu_b_16_21a_101 == "开店" | stu_b_16_21a_101 == "个人工作室" | stu_b_16_21a_101 == "监理" | stu_b_16_21a_101 == "监理员" | stu_b_16_21a_101 == "监理工程师" | stu_b_16_21a_101 == "行政主任" | stu_b_16_21a_101 == "装修包工头" | stu_b_16_21a_101 == "项目经理" | stu_b_16_21a_101 == "技术负责人"
replace facareer = 6 if stu_b_16_21a_101 == "书记" | stu_b_16_21a_101 == "事业单位" | stu_b_16_21a_101 == "事业单位专业技术人员" | stu_b_16_21a_101 == "交警" | stu_b_16_21a_101 == "住建局职员" | stu_b_16_21a_101 == "公务人员" | stu_b_16_21a_101 == "公务员" | stu_b_16_21a_101 == "公务员(会计)" | stu_b_16_21a_101 == "公安局" | stu_b_16_21a_101 == "军人" | stu_b_16_21a_101 == "国企" | stu_b_16_21a_101 == "国企(会计师主任)" | stu_b_16_21a_101 == "国企人员" | stu_b_16_21a_101 == "国企员工" | stu_b_16_21a_101 == "国企干部" | stu_b_16_21a_101 == "国企管理层" | stu_b_16_21a_101 == "国企职员" | stu_b_16_21a_101 == "国家电网" | stu_b_16_21a_101 == "在工商分局上班" | stu_b_16_21a_101 == "基层干部" | stu_b_16_21a_101 == "央企职工" | stu_b_16_21a_101 == "市消防局具体职位不知" | stu_b_16_21a_101 == "干部" | stu_b_16_21a_101 == "政府普通职员" | stu_b_16_21a_101 == "教育局" | stu_b_16_21a_101 == "机关单位员工" | stu_b_16_21a_101 == "民警" | stu_b_16_21a_101 == "气象局职员" | stu_b_16_21a_101 == "法庭科员" | stu_b_16_21a_101 == "稽查员" | stu_b_16_21a_101 == "警官" | stu_b_16_21a_101 == "警察"
tab facareer,m
*母亲职业
tab stu_b_16_21_102,m
gen mocareer = .
replace mocareer = 1 if stu_b_16_21_102 == 3
replace mocareer = 2 if stu_b_16_21_102 == 2
replace mocareer = 3 if stu_b_16_21_102 == 5 | stu_b_16_21_101 == 6
replace mocareer = 4 if stu_b_16_21_102 == 7
replace mocareer = 5 if stu_b_16_21_102 == 4
replace mocareer = 6 if stu_b_16_21_102 == 8
tab mocareer,m
tab stu_b_16_21a_102
replace mocareer = 1 if stu_b_16_21a_102 == "下岗" | stu_b_16_21a_102 == "下岗待业" | stu_b_16_21a_102 == "下岗职工" | stu_b_16_21a_102 == "下岗待业职工" | stu_b_16_21a_102 == "丧失劳动能力" | stu_b_16_21a_102 == "卧病在床" | stu_b_16_21a_102 == "失业" | stu_b_16_21a_102 == "失踪" | stu_b_16_21a_102 == "家庭主妇" | stu_b_16_21a_102 == "已退休" | stu_b_16_21a_102 == "待业" | stu_b_16_21a_102 == "患病" | stu_b_16_21a_102 == "患病残疾在家" | stu_b_16_21a_102 == "无" | stu_b_16_21a_102 == "无业" | stu_b_16_21a_102 == "无工作" | stu_b_16_21a_102 == "无职业" | stu_b_16_21a_102 == "没有工作" | stu_b_16_21a_102 == "生病在家" | stu_b_16_21a_102 == "病退" | stu_b_16_21a_102 == "退休" | stu_b_16_21a_102 == "退休在家" | stu_b_16_21a_102 == "退休工人" 
replace mocareer = 2 if stu_b_16_21a_102 == "县老干局临工" | stu_b_16_21a_102 == "散工" | stu_b_16_21a_102 == "渔业养殖" | stu_b_16_21a_102 == "牧业"
replace mocareer = 3 if stu_b_16_21a_102 == "个体" | stu_b_16_21a_102 == "个体商户" | stu_b_16_21a_102 == "个体户" | stu_b_16_21a_102 == "出租房屋" | stu_b_16_21a_102 == "出租车司机" | stu_b_16_21a_102 == "司机" | stu_b_16_21a_102 == "售票员" | stu_b_16_21a_102 == "商贩" | stu_b_16_21a_102 == "小商贩" | stu_b_16_21a_102 == "收银员" | stu_b_16_21a_102 == "柜员" | stu_b_16_21a_102 == "清洁工" | stu_b_16_21a_102 == "环卫工人" | stu_b_16_21a_102 == "私人家政" | stu_b_16_21a_102 == "自由个体" | stu_b_16_21a_102 == "自由职业" | stu_b_16_21a_102 == "营业员" 
replace mocareer = 4 if stu_b_16_21a_102 == "上班族" | stu_b_16_21a_102 == "业务员" | stu_b_16_21a_102 == "主持人" | stu_b_16_21a_102 == "代理员" | stu_b_16_21a_102 == "会计" | stu_b_16_21a_102 == "会计师" | stu_b_16_21a_102 == "公司员工" | stu_b_16_21a_102 == "公司职员" | stu_b_16_21a_102 == "农艺师" | stu_b_16_21a_102 == "出纳" | stu_b_16_21a_102 == "办事员" | stu_b_16_21a_102 == "医师" | stu_b_16_21a_102 == "医护人员" | stu_b_16_21a_102 == "医生" | stu_b_16_21a_102 == "医院" | stu_b_16_21a_102 == "医院医生" | stu_b_16_21a_102 == "医院后勤" | stu_b_16_21a_102 == "医院护士" | stu_b_16_21a_102 == "医院职员" | stu_b_16_21a_102 == "单位工程师" | stu_b_16_21a_102 == "厂外营销" | stu_b_16_21a_102 == "员工" | stu_b_16_21a_102 == "在职人员" | stu_b_16_21a_102 == "工程师" | stu_b_16_21a_102 == "广电局员工" | stu_b_16_21a_102 == "技术人员" | stu_b_16_21a_102 == "抄股" | stu_b_16_21a_102 == "护士" | stu_b_16_21a_102 == "护士长" | stu_b_16_21a_102 == "护师" | stu_b_16_21a_102 == "教师" | stu_b_16_21a_102 == "文员" | stu_b_16_21a_102 == "日报社" | stu_b_16_21a_102 == "普通科员政府部门但不是公务员" | stu_b_16_21a_102 == "普通职员" | stu_b_16_21a_102 == "查新" | stu_b_16_21a_102 == "校医" | stu_b_16_21a_102 == "档案员" | stu_b_16_21a_102 == "气象局职员" | stu_b_16_21a_102 == "演员" | stu_b_16_21a_102 == "电视台员工" | stu_b_16_21a_102 == "电视编辑" | stu_b_16_21a_102 == "研究所" | stu_b_16_21a_102 == "私企职员" | stu_b_16_21a_102 == "科员" | stu_b_16_21a_102 == "职员" | stu_b_16_21a_102 == "职工" | stu_b_16_21a_102 == "质检员" | stu_b_16_21a_102 == "金融从业员" | stu_b_16_21a_102 == "银行" | stu_b_16_21a_102 == "银行人员" | stu_b_16_21a_102 == "银行员工" | stu_b_16_21a_102 == "银行工作人员" | stu_b_16_21a_102 == "银行柜员" | stu_b_16_21a_102 == "银行职员" | stu_b_16_21a_102 == "预算员"
replace mocareer = 5 if stu_b_16_21a_102 == "企业管理人员" | stu_b_16_21a_102 == "保险公司经理" | stu_b_16_21a_102 == "副院长" | stu_b_16_21a_102 == "办公室主任" | stu_b_16_21a_102 == "干部" | stu_b_16_21a_102 == "干部军校" | stu_b_16_21a_102 == "社区主任" | stu_b_16_21a_102 == "管理" | stu_b_16_21a_102 == "装修包工头" | stu_b_16_21a_102 == "银行主任" | stu_b_16_21a_102 == "销售经理" 
replace mocareer = 6 if stu_b_16_21a_102 == "事业单位" | stu_b_16_21a_102 == "事业单位专业技术人员" | stu_b_16_21a_102 == "事业单位工作人员" | stu_b_16_21a_102 == "事业单位工作人员" | stu_b_16_21a_102 == "事业单位职员" | stu_b_16_21a_102 == "公务员" | stu_b_16_21a_102 == "公安" | stu_b_16_21a_102 == "包钢职工" | stu_b_16_21a_102 == "卫生监督所" | stu_b_16_21a_102 == "国企(会计)" | stu_b_16_21a_102 == "国企员工" | stu_b_16_21a_102 == "国企职员" | stu_b_16_21a_102 == "基层公务员" | stu_b_16_21a_102 == "央企" | stu_b_16_21a_102 == "央企职工" | stu_b_16_21a_102 == "居委" | stu_b_16_21a_102 == "居委会" | stu_b_16_21a_102 == "居委会干事" | stu_b_16_21a_102 == "政府干部" | stu_b_16_21a_102 == "科长" | stu_b_16_21a_102 == "税务局科员" | stu_b_16_21a_102 == "编制职员" | stu_b_16_21a_102 == "街道办" 
tab mocareer,m
*父母职业
gen parentcareer = facareer
tab parentcareer,m
replace parentcareer = mocareer if facareer == .
tab parentcareer,m
drop if parentcareer == .
replace parentcareer = mocareer if mocareer > facareer & mocareer != .
tab parentcareer,m
egen sd_parentcareer = std(parentcareer)
tab sd_parentcareer,m

**父母文化程度  sd_parenteduyear
tab stu_b_16_19_101,m
tab stu_b_16_19_102,m
gen parentedu = stu_b_16_19_101
replace parentedu = stu_b_16_19_102 if stu_b_16_19_101 == . | stu_b_16_19_101 == 16
replace parentedu = stu_b_16_19_102 if stu_b_16_19_102 > stu_b_16_19_101 & stu_b_16_19_102 != . & stu_b_16_19_102 != .n & stu_b_16_19_102 != 16
tab parentedu,m
*2没上过学0
*3小学没毕业3  
*4小学6  5初中没毕业6
*6初中9  9中专没毕业9  7高中没毕业9
*10中专11 
*8高中12  11大专没毕业12 13本科没毕业12
*12大专15
*14本科16  15研究生及以上16
gen parenteduyear = .
replace parenteduyear = 0 if parentedu == 2
replace parenteduyear = 3 if parentedu == 3
replace parenteduyear = 6 if parentedu == 4 | parentedu == 5
replace parenteduyear = 9 if parentedu == 6 | parentedu == 7 | parentedu == 9 
replace parenteduyear = 11 if parentedu == 10
replace parenteduyear = 12 if parentedu == 8 | parentedu == 11 | parentedu == 13
replace parenteduyear = 15 if parentedu == 12
replace parenteduyear = 16 if parentedu == 14 | parentedu == 15
tab parenteduyear,m
egen sd_parenteduyear = std(parenteduyear)
tab sd_parenteduyear,m

**家庭社会经济地位排名是否在后25%   SES2 
**主成分分析
*kom:0.9以上非常适合,0.8适合,0.7一般,0.6表示不太适合,0.5↓极不适合
pca sd_famasset sd_parenteduyear sd_parentcareer //第一个主成分特征值是2.005
predict f1 f2 f3
/*
    --------------------------------------------
        Variable |    Comp1     Comp2     Comp3 
    -------------+------------------------------
     sd_famasset |   0.5923   -0.1160   -0.7973 
    sd_parente~r |   0.5741   -0.6335    0.5187 
    sd_parentc~r |   0.5653    0.7650    0.3086 
    --------------------------------------------
*/
estat kmo //0.6879
gen SES = (0.593*sd_famasset + 0.574*sd_parenteduyear + 0.565*sd_parentcareer)/2.005
tab SES,m

sum SES,d // 前25%：<-0.5678，中间50%：>=-0.5678 <0.5959，后25%：>0.5959;50%: -0.0440205
gen SES2 = .
replace SES2 = 1 if SES <= -0.5678
replace SES2 = 0 if SES > -0.5678
tab SES2,m

**教师职业认同 sd_stu_profession_score
egen stu_profession_score = rowtotal (stu_b_16_1_2-stu_b_16_52_2)
egen sd_stu_profession_score = std(stu_profession_score)

**是否有教师职业理想 prefer
tab stu_b_16_51,m
rename stu_b_16_51 norm_moti

foreach x of numlist 1/9{
    gen norm_r`x'=.
	replace norm_r`x'=1 if regexm(norm_moti,"`x'")==1 & fnormalstu==1
	replace norm_r`x'=0 if regexm(norm_moti,"`x'")==0 & fnormalstu==1
	tab norm_r`x',m
	}
rename norm_r2 prefer 

**标准化高考英语成绩 sd_gk_engscore
rename stu_b_16_35a gk_engscore
egen sd_gk_engscore = std(gk_engscore)

************描述性表格******************
*专业
count if mdepressed > 2 & major == 1
count if mdepressed > 2 & major == 0
*年龄
count if mdepressed > 2 & age <= 17
count if mdepressed > 2 & age ==18
count if mdepressed > 2 & age ==19
count if mdepressed > 2 & age >=20
*年龄分两段
count if mdepressed > 2 & age2 == 0
count if mdepressed > 2 & age2 == 1
*性别
count if mdepressed > 2 & gender == 0
count if mdepressed > 2 & gender == 1
*民族
count if mdepressed > 2 & nation == 1
count if mdepressed > 2 & nation == 0
*户籍
count if mdepressed > 2 & hukou == 1
count if mdepressed > 2 & hukou == 0
*是否独生子女
count if mdepressed > 2 & onlychild == 1
count if mdepressed > 2 & onlychild == 0
*家庭社会经济地位
count if mdepressed > 2 & SES3 == 1
count if mdepressed > 2 & SES3 == 0
*毕业高中类型 stu_b_16_30
count if mdepressed >2 & stu_b_16_30==1
count if mdepressed >2 & stu_b_16_30==2
count if mdepressed >2 & stu_b_16_30==3
count if mdepressed >2 & stu_b_16_30==4
*理工科/社会科学类
count if mdepressed >2 & major ==1
count if mdepressed >2 & major ==0
*是否免费师范生
count if mdepressed > 2 & fnormalstu == 1
count if mdepressed > 2 & fnormalstu == 0
*自我主导型/非自我主导型公费师范生
count if mdepressed > 2 & stu_selfmotiv == 1
count if mdepressed > 2 & stu_selfmotiv == 0 //important!
*第一志愿专业
count if mdepressed > 2 & zhiyuan == 1
count if mdepressed > 2 & zhiyuan == 0

*************方差分析***************
reg gender depressed
	test depressed  //方差分析
reg age1 depressed
	test depressed  //方差分析
reg nation depressed
	test depressed  //方差分析
reg hukou depressed
	test depressed  //方差分析
reg onlychild depressed
	test depressed  //方差分析
reg SES3 depressed
	test depressed  //方差分析
reg stu_b_16_30 depressed
	test depressed  //方差分析
reg major depressed
	test depressed  //方差分析
reg fnormalstu depressed
	test depressed  //方差分析
reg stu_selfmotiv depressed
	test depressed  //方差分析
reg zhiyuan depressed
	test depressed  //方差分析

*************回归******************

//是否公费师范生对抑郁的影响
xi:reg depressed fnormalstu
   est store m1
xi:reg depressed fnormalstu major zhiyuan age gender nation onlychild hukou SES3
   est store m2  
outreg2 [m1 m2] using "reg.xls", excel replace bdec(3) sdec(3)

//是否公费师范生对英语成绩的影响
xi:reg sd_term_exam_总评成绩 fnormalstu
   est store w1
xi:reg sd_term_exam_总评成绩 fnormalstu  sd_gk_engscore  age gender nation  hukou sd_parenteduyear SES3
   est store w2  
outreg2 [w1 w2] using "reg2.xls", excel replace bdec(3) sdec(3)

//自我主导/非自我主导公费师范生对抑郁回归
*keep fnormalstu==1
xi:reg depressed stu_selfmotiv
   est store n1
xi:reg depressed stu_selfmotiv major zhiyuan age gender nation onlychild hukou SES3
   est store n2 
outreg2 [n1 n2]using reg3.xls, excel replace bdec(2) sdec(2)

//教师职业认同对抑郁回归
xi:reg depressed sd_stu_profession_score
   est store n1
xi:reg depressed sd_stu_profession_score major zhiyuan age gender nation onlychild hukou SES3
   est store n2 
outreg2 [n1 n2]using reg4.xls, excel replace bdec(2) sdec(2)

//自我主导/非自我主导公费师范生对英语成绩回归
*keep if fnormalstu==1
xi:reg sd_term_exam_总评成绩 stu_selfmotiv
   est store k1
xi:reg sd_term_exam_总评成绩 stu_selfmotiv sd_gk_engscore major zhiyuan age gender nation onlychild hukou SES3
   est store k2 
xi:reg sd_term_exam_总评成绩 stu_selfmotiv sd_gk_engscore major zhiyuan age gender nation onlychild hukou SES3 prefer
   est store k3
outreg2 [k1 k2 k3] using reg5.xls, excel replace bdec(2) sdec(2)

//非公费师范生中所学专业是否是第一志愿专业对抑郁回归
*keep if fnormalstu==0
xi:reg depressed zhiyuan
   est store k1
xi:reg depressed zhiyuan major age gender nation onlychild hukou SES3
   est store k2 
outreg2 [k1 k2]using reg6.xls, excel replace bdec(2) sdec(2)



