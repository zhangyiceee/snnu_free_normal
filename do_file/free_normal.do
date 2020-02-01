 *============================================================*
**       		 免费师范生项目  
**Goal		:    免费师范生的教师职业选择的影响因素
**Data		:    2016ji_student_dataset.dta
**Author	:  	 ZhangYi 
**Created	:  	 20191213 
**Last Modified: 2019
*============================================================*
*============================================================*
	capture	clear
	capture log close
	set	more off
	set scrollbufsize 2048000
	capture log close 

*张毅	
	cd "/Users/zhangyi/Documents/数据集/free_normal/raw_data"
	global cleandir "/Users/zhangyi/Documents/数据集/free_normal/clean_data"
	global outdir "/Users/zhangyi/Documents/数据集/free_normal/output"
	global date "1213" //每次检查时修改日期，生成新的结果、
*王欢
	cd "C:\Users\wangh\Desktop\公费师范生报告\第六章抑郁数据处理\rawdata"
	global cleandir "C:\Users\wangh\Desktop\公费师范生报告\第六章抑郁数据处理\save"
	global outdir "C:\Users\wangh\Desktop\公费师范生报告\第六章抑郁数据处理\working"
	global date "1213" //每次检查时修改日期，生成新的结果、

	
*调用数据
*
	use "2016ji student dataset.dta",clear

*===============*
*对数据进行清理
*===============*
	
	keep if regexm(学号, "^[4][1][6][0-2][0-9][0-9][0-9][0-9]$" ) == 1 & stu_b_16_stuid != "" & stu_b_16_stuname != ""
	rename 学号 stuid

*==========*
*自变量*
*==========*	
	
***是否为免费师范生 stu_normal
	codebook  stu_b_16_47 //免费师范生==1 非免费师范生==2 非师范生==3
	gen stu_normal=.
		replace stu_normal = 1 if stu_b_16_47 == 1
		replace stu_normal = 0 if stu_b_16_47 == 2 | stu_b_16_47 == 3
	label define normal 1 "免费师范生" 0 "非师范生"
	label values stu_normal normal
	tab stu_normal,m  //免费师范生1978个；非师范生2289个
	
***自我主导和非自我主导型免费师范生——stu_major
	gen  stu_selfmotiv=2-stu_b_16_52 //1=自我主导的报考生 0=非自我主导的报考生
	label var stu_selfmotiv "自我主导=1 非自我主导=0"
	tab stu_selfmotiv,m 
	
*==========*
*个人基本情况*
*==========*
*1.学生性别  student_female
	codebook stu_b_16_3
	gen stu_male=.
	replace stu_male=1 if stu_b_16_3==1
	replace stu_male=0 if stu_b_16_3==2
	label define sex 1"男" 0"女",replace
	label values stu_male sex
	codebook stu_male
*2.学生年龄 stu_age
	tab stu_b_16_1,m
	replace stu_b_16_1 ="." if stu_b_16_1==".o"
	destring stu_b_16_1,replace
	tab stu_b_16_2,m
	destring stu_b_16_2,replace 

	gen stu_age = int(((2015 - stu_b_16_1)*12 + (21 - stu_b_16_2)) / 12)
	tab stu_age,m //回归使用此变量，连续性

*3.民族 stu_ethnic
	clonevar stu_ethnic = stu_b_16_4
	codebook stu_ethnic
	recode stu_ethnic (1=0)(2 3 4 5 6 7=1)
	label define minzu 1"少数民族" 0 "汉族"
	label values stu_ethnic minzu
	codebook stu_ethnic

*4.学生户籍 rural_hukou
	codebook stu_b_16_5
	clonevar rural_hukou = stu_b_16_5
	recode rural_hukou (2=0)(3=.)
	label define hukou1 1"农村户口"0"城镇户口"
	label values rural_hukou hukou1
	codebook rural_hukou //农村户口1 城镇户口0

*5.是否为独生子女 only_child
	gen only_child = 1
	foreach i of numlist 1/4 {
   		replace only_child = 0 if regexm(stu_b_16_11_10`i',"3") == 1 | regexm(stu_b_16_11_10`i',"4") == 1 | regexm(stu_b_16_11_10`i',"5") == 1 | regexm(stu_b_16_11_10`i',"6") == 1 
 	}

 	foreach i of numlist 5/9 {
 		replace only_child = 0 if  stu_b_16_11_10`i' == 3 |stu_b_16_11_10`i' == 4 |stu_b_16_11_10`i' == 5 |stu_b_16_11_10`i' == 6
 	}
 	codebook only_child
 	label define onlyone 1"独生子女"0"非独生子女"
 	label values only_child onlyone

*家庭社会经济地位 SES
	recode stu_b_16_27 (2=0) 
	foreach i in a b c d e f g h {
		recode stu_b_16_28`i' (2=0)
	} 

	egen famasset = rowtotal(stu_b_16_27 - stu_b_16_28h)
	egen sd_famasset = std(famasset)

	tab sd_famasset , m

*父母文化程度 sd_parenteduyear

	tab stu_b_16_19_101,m
	tab stu_b_16_19_102,m
	gen parentedu = stu_b_16_19_101
	replace parentedu = stu_b_16_19_102 if stu_b_16_19_101==. |stu_b_16_19_101 ==16
	replace parentedu = stu_b_16_19_102 if stu_b_16_19_102 > stu_b_16_19_101 &stu_b_16_19_102 != . &stu_b_16_19_102 != .n &stu_b_16_19_102 !=16 
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
	replace parenteduyear = 0  if parentedu == 2
	replace parenteduyear = 3  if parentedu == 3
	replace parenteduyear = 6  if parentedu == 4 | parentedu == 5
	replace parenteduyear = 9  if parentedu == 6 | parentedu == 7 | parentedu == 9 
	replace parenteduyear = 11 if parentedu ==10
	replace parenteduyear = 12 if parentedu == 8 | parentedu == 11 | parentedu == 13
	replace parenteduyear = 15 if parentedu == 12
	replace parenteduyear = 16 if parentedu == 14 | parentedu == 15
	tab parenteduyear , m
	egen sd_parenteduyear = std(parenteduyear)
	tab sd_parenteduyear,m

*父母职业 sd_parentcareer
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


**主成分分析
*kmo:0.9以上非常适合,0.8适合,0.7一般,0.6表示不太适合,0.5以下极不适合
	pca sd_famasset sd_parenteduyear sd_parentcareer //第一个主成分特征值是2.006
	predict f1 f2 f3

/*
 	-----------------------------------------
        Variable |    Comp1     Comp2     Comp3 
    -------------+------------------------------
     sd_famasset |   0.5919   -0.1196   -0.7971 
    sd_parente~r |   0.5743   -0.6313    0.5212 
    sd_parentc~r |   0.5655    0.7663    0.3050 
    --------------------------------------------

*/
	estat kmo //0.6884
	gen SES = (0.591 * sd_famasset +0.574* sd_parenteduyear + 0.565 * sd_parentcareer) /2.006
	tab SES , m //将此项放入回归中
	xtile SES_qt=SES , n(4)
	recode SES_qt (2 3=2)(4=3)

*7.是否为重点高中 stu_b_16_30
	tab stu_b_16_30 , m //1：省示范高中；2:市示范高中；3:普通高中
	tab stu_b_16_30a , m 
	replace stu_b_16_30 = 1 if stu_b_16_30a == "(容县高中)"
	replace stu_b_16_30 = 2 if stu_b_16_30a == "(通渭县第一中学)"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "(重庆市涪陵第五中学校)"
	list stu_b_16_stuid if stu_b_16_30a=="??高级中学"
	replace stu_b_16_30a = "和静高级中学" if stu_b_16_30a== "??高级中学" & stu_b_16_stuid=="111901104"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "和静高级中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "万年中学(江西)"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "万荣中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "三亚市第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "三门峡市外国语高级中学"
	replace stu_b_16_30 = 2 if stu_b_16_30a == "上海市七宝中学"
	replace stu_b_16_30 = 2 if stu_b_16_30a == "上海市同济大学附属七一中学区级示范高中"
	replace stu_b_16_30 = 2 if stu_b_16_30a == "上海市嘉定区嘉定一中"
	replace stu_b_16_30 = 2 if stu_b_16_30a == "上海市嘉定区第一中学"
	replace stu_b_16_30 = 2 if stu_b_16_30a == "上海市崇明中学"
	replace stu_b_16_30 = 2 if stu_b_16_30a == "上海市浦东新区上海南汇中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "上海市第八中学" //黄浦区区重点中学
	replace stu_b_16_30 = 1 if stu_b_16_30a == "上饶市饶州中学"
	list stu_b_16_stuid if stu_b_16_30a == "不清楚七台河市第一中学"
	replace stu_b_16_30a = "七台河市第一中学" if stu_b_16_30a=="不清楚七台河市第一中学"& stu_b_16_stuid=="110104009"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "七台河市第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "东丰县第二中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "东华高级中学" //私立高中
	replace stu_b_16_30 = 1 if stu_b_16_30a == "东川明月中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "东莞市东华高级中学" //私立高中
	replace stu_b_16_30 = 3 if stu_b_16_30a == "中央民族大学附属中学" //国家级特色高中建设校
	replace stu_b_16_30 = 3 if stu_b_16_30a == "中恒学校" //公助民办性质的普通高中
	replace stu_b_16_30 = 1 if stu_b_16_30a == "临川一中"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "临泉一中"
	list stu_b_16_stuid if stu_b_16_30a == "临海铁路中学"
	replace stu_b_16_30a = "临潼铁路中学" if stu_b_16_30a=="临海铁路中学"& stu_b_16_stuid=="111901041"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "临潼铁路中学" //完全中学
	replace stu_b_16_30 = 1 if stu_b_16_30a == "丹凤中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "义龙实验区第一高级中学" //公立高级中学
	replace stu_b_16_30 = 1 if stu_b_16_30a == "乌鲁木齐市第八中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "乌鲁木齐市高级中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "云南建水第一中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "云南省大理州民族中学" //国家科技部“863”项目远程教育示范校 寄宿制民族中学
	replace stu_b_16_30 = 3 if stu_b_16_30a == "云南省曲靖市富源县第一中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "云南省玉溪市民族中学" //定寄宿制民族高级中学
	list stu_b_16_stuid if stu_b_16_30a == "云南省由靖市陆良县第一中学"
	replace stu_b_16_30a = "云南省曲靖市陆良县第一中学" if stu_b_16_30a=="云南省由靖市陆良县第一中学"& stu_b_16_stuid=="111302081"
	replace stu_b_16_30 = 2 if stu_b_16_30a == "云南省曲靖市陆良县第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "仁怀市第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "从化市第六中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "任丘市第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "伊川县第一高中"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "伊通满族自治县第一中学"
	replace stu_b_16_30 = 2 if stu_b_16_30a == "会宁二中"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "佛山市实验学校" //佛山市禅城区品牌学校、广东省一级学校
	replace stu_b_16_30 = 1 if stu_b_16_30a == "佛山第三中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "佳木斯市第一中学"
	replace stu_b_16_30 = 2 if stu_b_16_30a == "儋州市第一中学"
	list stu_b_16_stuid if stu_b_16_30a == "全国重点中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "全国重点中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "六盘山高级中学" //全日制、寄宿制重点示范高中
	replace stu_b_16_30 = 1 if stu_b_16_30a == "兴义中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "兴平市西郊高级中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "凤翔县凤翔中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "凯里市第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "务川中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "勉县第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "包头市第一中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "包钢五中" //内蒙古师范大学第二附属中学
	replace stu_b_16_30 = 1 if stu_b_16_30a == "化州市第一中学(广东省)"
	list stu_b_16_stuid if stu_b_16_30a == "北京3九中"
	replace stu_b_16_30a = "北京九中" if stu_b_16_30a == "北京3九中"& stu_b_16_stuid=="110501104"
	replace stu_b_16_30 = 2 if stu_b_16_30a == "北京九中"
	replace stu_b_16_30 = 2 if stu_b_16_30a == "北京市昌平区第一中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "北川中学" //省级实验示范校
	replace stu_b_16_30 = 1 if stu_b_16_30a == "北流市高级中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "北重三中"
	list stu_b_16_stuid if stu_b_16_30a == "区级重点高中"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "区级重点高中"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "华山中学(新疆)" //新疆生产建设兵团重点试验中学和国家“现代教育技术实验学校
	replace stu_b_16_30 = 1 if stu_b_16_30a == "南川中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "南昌大学附属中学"
	replace stu_b_16_30 = 2 if stu_b_16_30a == "南江县长赤中学" //四川省普通高中二级示范学校
	replace stu_b_16_30 = 1 if stu_b_16_30a == "南郑中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "南阳市五中"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "南阳市第五中学"
	list stu_b_16_stuid if stu_b_16_30a == "博士园私立高中"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "博士园私立高中"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "即墨市实验高级中学" //即墨区三所重点高中之一
	replace stu_b_16_30 = 1 if stu_b_16_30a == "即墨第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "厦门一中"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "厦门市第二外国语学校" //省一级达标高中
	replace stu_b_16_30 = 3 if stu_b_16_30a == "厦门科技中学" //福建省一级达标学校
	replace stu_b_16_30 = 3 if stu_b_16_30a == "厦门集美中学" //福建省一级达标学校
	list stu_b_16_stuid if stu_b_16_30a == "县级示范高中"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "县级示范高中"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "合肥市第七中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "合阳中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "吉林市第十二中学校"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "吉林省前郭县第五高级中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "吉林省吉林市吉化第一高级中学校"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "吉林省延边第二中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "咸阳彩虹中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "咸阳渭城中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "哈密地区二中"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "哈尔滨市第七十三中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "唐山市第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "商丘市第一高级中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "商水县第二高级中学" //周口市“教育教学先进单位”
	replace stu_b_16_30 = 1 if stu_b_16_30a == "商洛中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "嘉峪关市第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "四川成都双流县棠湖中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "四川省宣汉中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "四川省德阳市第五中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "四川省成都七中八一学校" //成都军区国防生源基地学校
	replace stu_b_16_30 = 1 if stu_b_16_30a == "四川省成都市新都一中" //四川省首批省级重点中学、国家级示范性普通高中
	replace stu_b_16_30 = 1 if stu_b_16_30a == "四川省眉山市中学校"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "四川省绵阳南山中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "围场县第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "固原一中"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "国家级示范性高中"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "国家级示范高中"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "国家级示范高中、绵阳中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "国家级示范高中江苏省宿迁中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "国家重点高中"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "城固一中"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "城固县第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "城固第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "塔城地区第一高级中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "大通二中"
	replace stu_b_16_30 = 2 if stu_b_16_30a == "天津市大港第一中学"
	replace stu_b_16_30 = 2 if stu_b_16_30a == "天津市滨海新区大港一中"
	replace stu_b_16_30 = 2 if stu_b_16_30a == "天津市第七中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "天津市静海光明中学" //县重点
	replace stu_b_16_30 = 1 if stu_b_16_30a == "太原市小店区第一中学校"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "太原市金河中学" //县办高级中学
	replace stu_b_16_30 = 1 if stu_b_16_30a == "太康一高"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "太康县第一高级中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "太谷职业中学校" //国家级重点职业高中
	replace stu_b_16_30 = 2 if stu_b_16_30a == "宁城高级中学(内蒙古赤峰市)"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "宁夏六盘山高中"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "宁夏六盘山高级中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "宁夏固原一中"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "宁夏固原市第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "宁夏省六盘山高级中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "宁夏省固原市回民中学" //只说是示范高中，未说明是省级还是市级
	replace stu_b_16_30 = 1 if stu_b_16_30a == "宁夏西吉中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "宁夏银川市六盘山高级中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "宁夏银川市第二十四中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "宁强县天津高级中学" //省级标准化高中
	replace stu_b_16_30 = 3 if stu_b_16_30a == "安宁中学" //云南省一级一等完全中学
	replace stu_b_16_30 = 1 if stu_b_16_30a == "安工大附中"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "安康中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "安康市高新中学" //私立民办中学
	replace stu_b_16_30 = 3 if stu_b_16_30a == "安康长兴学校" //全日制寄宿民办学校
	list stu_b_16_stuid if stu_b_16_30a == "安康高新"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "安康高新" //私立民办中学
	replace stu_b_16_30 = 3 if stu_b_16_30a == "安康高新中学" //私立民办中学
	replace stu_b_16_30 = 1 if stu_b_16_30a == "安徽省亳州一中"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "安徽省寿县第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "安徽省青阳中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "安阳市正一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "定襄中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "定边中学"
	list stu_b_16_stuid if stu_b_16_30a == "宜川朝阳中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "宜川朝阳中学" //没有查到
	replace stu_b_16_30 = 1 if stu_b_16_30a == "宜昌市长阳县第一高级中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "宝丰一高"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "宝安中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "宝鸡中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "宝鸡石油中学"
	replace stu_b_16_30 = 2 if stu_b_16_30a == "宣威市第一中学"
	replace stu_b_16_30 = 2 if stu_b_16_30a == "寿光市第一中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "寿光现代中学" //现代化重点高中、寿光城区的两所重点高中之一
	list stu_b_16_stuid if stu_b_16_30a == "尧山中学" //蒲城县尧山中学
	replace stu_b_16_30 = 1 if stu_b_16_30a == "尧山中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "山东日照实验高中"
	replace stu_b_16_30 = 2 if stu_b_16_30a == "山东潍坊滨海中学"
	replace stu_b_16_30 = 2 if stu_b_16_30a == "山东省五莲县五莲一中"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "山东省即墨市第一中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "山东省泰安英雄中学" //山东省规范化学校、岱岳区重点完全中学
	replace stu_b_16_30 = 1 if stu_b_16_30a == "山东省济宁市第一中学"
	replace stu_b_16_30 = 2 if stu_b_16_30a == "山东省章丘市第四中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "山东省聊城市第二中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "山东省聊城第一中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "山东省胶州一中" //国有民办全日制普通高级中学、山东省规范化学校
	replace stu_b_16_30 = 3 if stu_b_16_30a == "山东省胶州市第一中学" //同上
	replace stu_b_16_30 = 1 if stu_b_16_30a == "山东省荣成市第六中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "山东省莒南县第三中学" //省级规范化学校、省级绿色学校
	replace stu_b_16_30 = 1 if stu_b_16_30a == "山东省莱芜市第一中学"
	list stu_b_16_stuid if stu_b_16_30a == "山东省青岛胶州市" //未说明学校
	replace stu_b_16_30 = 1 if stu_b_16_30a == "山西大学附属中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "山西省吕梁市高级中学" //中国民办教育百强学校、中国民办五星级示范学校
	replace stu_b_16_30 = 1 if stu_b_16_30a == "山西省康杰中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "山西省晋中市昔阳县昔阳中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "山西省朔州市第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "山西省朔州市第一中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "山西省柳林联盛中学" //一所“民办公助”体制的封闭式全日制完全中学
	replace stu_b_16_30 = 1 if stu_b_16_30a == "山西省范亭中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "山西省长治市一中"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "山阳中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "州级示范高中"
	replace stu_b_16_30a = "常州市北郊高级中学" if stu_b_16_30a=="常州市北郊高贝中学"& stu_b_16_stuid=="110301153"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "常州市北郊高级中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "常州市第五中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "平乐县民族中学" //没有查到
	replace stu_b_16_30 = 1 if stu_b_16_30a == "平顶山市一中"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "广东省东莞市东莞中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "广东省佛山实验中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "广东省国家级示范性高中"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "广东顺德李兆基中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "广州七中"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "广州市真光中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "广州市第47中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "广昌第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "广水第一高级中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "广西南宁市希望高中" //私立高中
	replace stu_b_16_30 = 1 if stu_b_16_30a == "广西壮族自治区玉林市玉林高级中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "广西大学附属中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "广西师范大学附属外国语学校"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "广西灵山县灵山中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "广西百色高级中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "库尔勒市第三中学" //全日制汉语完全中学
	replace stu_b_16_30 = 2 if stu_b_16_30a == "府谷县第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "延安中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "延安实验中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "延安市实验中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "延安第四中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "开远市第一中学" //云南省一级完全中学、全国文明单位，省级文明单位
	replace stu_b_16_30 = 1 if stu_b_16_30a == "张家口市第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "张家界市第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "怀远一中安徽省"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "恩施土家族苗族自治州第一高级中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "惠州市华罗庚中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "惠州市第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "成都市树德中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "户县第一中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "文登新一中" //山东省规范化学校、公立普通高级中学
	replace stu_b_16_30 = 3 if stu_b_16_30a == "新安二高"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "新安第一高级中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "新疆内地高中班"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "新疆和静高级中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "新疆实验中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "新疆巴州二中石油分校"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "新疆师范大学附属中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "新疆省乌鲁木齐市十二中"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "新疆省克拉玛依市高级中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "新疆省巴音郭楞蒙古自治州第二中学"
	replace stu_b_16_30 = 2 if stu_b_16_30a == "新郑二中分校"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "无极野风美术中学" //河北省明星美术学校
	replace stu_b_16_30 = 3 if stu_b_16_30a == "日照实验高级中学" //省级规范化重点中学
	replace stu_b_16_30 = 1 if stu_b_16_30a == "旬阳中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "昆明市第一中学" //云南省一级一等高级中学
	replace stu_b_16_30 = 3 if stu_b_16_30a == "昆明市第三中学" //云南省一级一等高级中学
	replace stu_b_16_30 = 3 if stu_b_16_30a == "昆明第十四中学" //云南省一级二等完全中学
	replace stu_b_16_30 = 3 if stu_b_16_30a == "昌吉州一中" //完全普通中学
	replace stu_b_16_30 = 1 if stu_b_16_30a == "普集高中"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "景德镇一中"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "杨村第一中学" //全日制寄宿式重点高级中学
	replace stu_b_16_30 = 1 if stu_b_16_30a == "松原市实验高中"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "柳州市一中"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "栾川县第一高级中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "桂林市第十八中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "桑植一中"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "榆林中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "榆林市一中"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "榆林市实验高中" //榆林市教育局直属完全中学，省级标准化高中
	replace stu_b_16_30 = 1 if stu_b_16_30a == "榆林市第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "榆树市实验高中"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "榆次二中"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "横山中学" //省级标准化高中
	replace stu_b_16_30 = 3 if stu_b_16_30a == "民办高中" //未说明学校
	replace stu_b_16_30 = 1 if stu_b_16_30a == "民和县第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "永昌县第一高级中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "永福县高级中学" //自治区一级高中
	replace stu_b_16_30 = 1 if stu_b_16_30a == "永顺县第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "汉中中学"
	list stu_b_16_stuid if stu_b_16_30a=="汉中市、举县中学"
	replace stu_b_16_30a = "汉中市、洋县中学" if stu_b_16_30a=="汉中市、举县中学"& stu_b_16_stuid=="111101069"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "汉中市、洋县中学"
	replace stu_b_16_30 = 2 if stu_b_16_30a == "汉中市陕飞一中"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "汉中市龙岗学校" //陕西省第一所民办基础教育示范学校
	replace stu_b_16_30 = 2 if stu_b_16_30a == "汝南高中"
	replace stu_b_16_30 = 2 if stu_b_16_30a == "汝南高级中学"
	replace stu_b_16_30 = 2 if stu_b_16_30a == "江津中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "江苏省奔牛高级中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "江苏省如东高级中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "江苏省昆山中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "江苏省海门中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "江苏省淮安中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "江苏省郑集高级中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "江西省丰城中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "江西省丰城市丰城中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "江西省景德镇市一中"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "江西省瑞昌市第二中学(省重点中学)"
	replace stu_b_16_30 = 2 if stu_b_16_30a == "汾阳市第五高级中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "沁阳市第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "河北承德第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "河北武邑中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "河北省唐山一中"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "河北省沧州市第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "河北省泊头市第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "河北省邯郸市第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "河北衡水中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "河南宏力学校"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "河南省南阳市新野县第一高级中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "河南省商城高级中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "河南省安阳市正一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "河南省平顶山市第一高中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "河南省栾川县第一高级中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "河南省洛阳市宜阳县第一高级中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "河南省洛阳市第一高级中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "河南省济源第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "河南省西平县高级中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "河南省鹤壁高中"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "河池高级中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "泰安市英雄山中学" //岱岳区区重点中学
	replace stu_b_16_30 = 1 if stu_b_16_30a == "洋县中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "洛阳理工学院附中"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "济源市第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "浏阳一中"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "海城市高级中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "海川高级中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "海泉学校" //民办学校“高考质量优胜单位”
	replace stu_b_16_30 = 1 if stu_b_16_30a == "淄博六中"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "深大附中"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "清徐县徐沟中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "清江外国语学校" //私立中学
	replace stu_b_16_30 = 1 if stu_b_16_30a == "温县第一高级中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "渭南市澄城中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "渭南高级中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "湖北黄陂一中"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "湖南省望城区第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "湖南省桂东县第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "湖南省益明市第六中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "湖南省长沙市第一中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "湖南长沙明达中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "湘潭市一中"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "湘西州民族中学"

	replace stu_b_16_30 = 1 if stu_b_16_30a == "漯河市第四高级中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "澄城中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "灵宝市第一高级中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "灵川中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "灵武市第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "烽火中学"
	replace stu_b_16_30 = 2 if stu_b_16_30a == "独山中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "玉山一中玉山县重点高中"
	list stu_b_16_stuid if stu_b_16_30a == "玉莲县第一中学"
	replace stu_b_16_30a = "五莲县第一中学" if stu_b_16_30a == "玉莲县第一中学"& stu_b_16_stuid == "111501063"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "五莲县第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "王力中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "环江毛难族自治县高级中学"

	replace stu_b_16_30 = 1 if stu_b_16_30a == "珠海一中"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "瑞泉中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "瓮安中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "甘肃省兰州新区舟曲中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "甘肃省平凉一中"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "甘肃省张掖市民乐一中"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "甘肃省武威第六中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "甘肃省民东县第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "甘肃省永昌县第一高级中学"
	replace stu_b_16_30 = 2 if stu_b_16_30a == "甘肃省玉门市第一中学"
	replace stu_b_16_30 = 2 if stu_b_16_30a == "甘肃省镇原中学"

	replace stu_b_16_30 = 1 if stu_b_16_30a == "甘谷第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "白城市第一中学"
	replace stu_b_16_30 = 2 if stu_b_16_30a == "白银市平川中学"
	replace stu_b_16_30 = 2 if stu_b_16_30a == "百色民族高级中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "盐田高级中学" //盐田区唯一的重点普通高中
	replace stu_b_16_30 = 2 if stu_b_16_30a == "监利中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "盘县第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "盘锦市高级中学"
	list stu_b_16_stuid if stu_b_16_30a == "省一级重点中学"
	replace stu_b_16_30a = "杭州市长河高级中学" if stu_b_16_30a == "省一级重点中学"& stu_b_16_stuid == "110101038" 
	replace stu_b_16_30 = 2 if stu_b_16_30a == "杭州市长河高级中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "石家庄市第六中学"
	replace stu_b_16_30 = 2 if stu_b_16_30a == "石柱中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "石河子一中"

	replace stu_b_16_30 = 1 if stu_b_16_30a == "石门一中"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "石门县第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "石阡中学(石阡第一中学)"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "神木中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "福州三中"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "福州第八中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "福建省同安第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "福建省泉州市安溪县第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "福建省长乐第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "福建长乐第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "私立诸暨高级中学"


	replace stu_b_16_30 = 3 if stu_b_16_30a == "章丘五中"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "第七师高级中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "纳溪中学"
	list stu_b_16_stuid if stu_b_16_30a == "绍兴市高边中学"
	replace stu_b_16_30a = "绍兴市高级中学" if stu_b_16_30a == "绍兴市高边中学"& stu_b_16_stuid == "112001055"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "绍兴市高级中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "绍兴鲁迅高级中学"
	replace stu_b_16_30 = 2 if stu_b_16_30a == "绥棱县第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "绵阳中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "绵阳中学实验学校" //私立高中 四川省十强高中
	replace stu_b_16_30 = 1 if stu_b_16_30a == "绵阳南山中学实验学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "罗定邦中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "耀州中学"

	replace stu_b_16_30 = 3 if stu_b_16_30a == "胶州市第一中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "腾冲县第一中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "腾冲县第七中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "腾冲市第一中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "腾冲第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "舒兰一中"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "莲塘一中"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "营口开发区第一高级中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "葫芦岛市第一高级中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "藤县中学" //区示范
	replace stu_b_16_30 = 3 if stu_b_16_30a == "虞城县第一高级中学"

	replace stu_b_16_30 = 1 if stu_b_16_30a == "虢镇中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "融安县第二中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "衡水二中)"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "襄阳四中"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "西乡二中"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "西乡县第二中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "西乡县第二中学(省级重点高中)"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "西北农林科技大学附属中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "西北师大附中"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "西吉中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "西宁五中"

	replace stu_b_16_30 = 3 if stu_b_16_30a == "西宁市第三中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "西宁市第二中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "西宁市第五高级中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "西安市东元路学校"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "西安市东城第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "西安市庆华中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "西安市庆安高级中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "西安市曲江第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "西安市第六十六中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "西安电子科技大学附中"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "西安铁一中滨学"

	replace stu_b_16_30 = 1 if stu_b_16_30a == "西安铁一中滨河学校"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "西峡县第一高级中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "西电科大附中"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "西电附中"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "西航一中"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "西飞第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "象贤中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "贞丰三立中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "贵州大学附属中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "贵州省毕节市七星关区毕节二中"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "贵阳清华中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "辽宁省朝阳市第二高级中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "辽宁省锦州市北镇高级中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "达拉特旗第一中学 "
	replace stu_b_16_30 = 1 if stu_b_16_30a == "迁安市第三中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "遵义市第二十一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "邢台市第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "邯郸市第一中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "邵东创新学校"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "郑州市第106中学" //唯一一所以美术为特色的河南省示范性高中
	replace stu_b_16_30 = 1 if stu_b_16_30a == "鄂尔多斯市第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "酒泉中学"
	replace stu_b_16_30 = 2 if stu_b_16_30a == "重庆市兼善中学"
	replace stu_b_16_30 = 2 if stu_b_16_30a == "重庆市凤鸣山中学"
	replace stu_b_16_30 = 2 if stu_b_16_30a == "重庆市垫江中学"
	replace stu_b_16_30 = 2 if stu_b_16_30a == "重庆市实验中学"
	list stu_b_16_stuid if stu_b_16_30a == "重庆市永坪中学"
	replace stu_b_16_30a = "重庆市杨家坪中学" if stu_b_16_30a == "重庆市永坪中学"& stu_b_16_stuid == "111302002"
	replace stu_b_16_30 = 2 if stu_b_16_30a == "重庆市杨家坪中学"
	replace stu_b_16_30 = 2 if stu_b_16_30a == "重庆市永川中学校"
	replace stu_b_16_30 = 2 if stu_b_16_30a == "重庆市永川区学"
	replace stu_b_16_30 = 2 if stu_b_16_30a == "重庆市求精中学校"
	replace stu_b_16_30 = 2 if stu_b_16_30a == "重庆市涪陵区实验中学"
	replace stu_b_16_30 = 2 if stu_b_16_30a == "重庆市渝北中学校"
	replace stu_b_16_30 = 2 if stu_b_16_30a == "重庆市第八中学"

	replace stu_b_16_30 = 2 if stu_b_16_30a == "重庆市第十一中学校"
	replace stu_b_16_30 = 2 if stu_b_16_30a == "重庆市育才中学校"
	replace stu_b_16_30 = 2 if stu_b_16_30a == "重庆市酉阳第一中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "重庆市黔江民族中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "金昌市第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "金陵中学河西分校"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "铜仁二中"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "铜川市第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "银川市第二中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "镇安中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "长安一中"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "长阳第一高级中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "闫良区西飞第一中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "陇南市武都第二中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "陇县第二高级中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "陕西勉县武侯中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "陕西咸阳中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "陕西延安中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "陕西省丹凤中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "陕西省商洛中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "陕西省城固县第一中学"
	replace stu_b_16_30 = 2 if stu_b_16_30a == "陕西省城固县第二中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "陕西省安康市安康中学"
	replace stu_b_16_30 = 2 if stu_b_16_30a == "陕西省定边中学"
	replace stu_b_16_30 = 2 if stu_b_16_30a == "陕西省定边县定边中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "陕西省宝鸡中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "陕西省宝鸡市烽火中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "陕西省山阳中学"
	replace stu_b_16_30 = 2 if stu_b_16_30a == "陕西省府谷中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "陕西省延安中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "陕西省延安市实验中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "陕西省延安市延安中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "陕西省榆林市神木县神木中学"

	replace stu_b_16_30 = 1 if stu_b_16_30a == "陕西省榆林市第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "陕西省神木中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "陕西省米脂中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "陕西省绥德县第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "陕西省西乡县第二中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "陕西省西安中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "陕西省西安市第89中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "陕西省西安市远东第二中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "陕西省西安市长安区第二中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "陕西省铜川市第一中学(北关校区)"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "陕西省铜川市耀州区耀州中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "陕西省镇安县镇安中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "隆德县中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "霍邱县第一中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "青光第一中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "青岛开发区第一中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "青岛第五十八中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "青海省乐都一中"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "青神中学校"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "靖西市靖西中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "靖边中学"
	replace stu_b_16_30 = 2 if stu_b_16_30a == "靖远二中"
	replace stu_b_16_30 = 2 if stu_b_16_30a == "静海区第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "首都师范大学附属桂林实验中学"
	list stu_b_16_stuid if stu_b_16_30a == "马苏市第一中学"
	replace stu_b_16_30a = "乌苏市第一中学" if stu_b_16_30a == "马苏市第一中学" & stu_b_16_stuid == "111401162"
	replace stu_b_16_30 = 2 if stu_b_16_30a == "乌苏市第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "马鞍山第二十二中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "驻马店高级中学"
	list stu_b_16_stuid if stu_b_16_30a == "高宏二中"
	replace stu_b_16_30a = "高安二中" if stu_b_16_30a == "高宏二中"& stu_b_16_stuid == "111101011"
	replace stu_b_16_30 = 2 if stu_b_16_30a == "高安二中"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "高安二中"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "高陵区第一中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "黄岛区第二中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "黑龙江省五大连池市实验中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "黑龙江省哈尔滨市双城区兆麟中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "黔东南州民族高级中学"
	replace stu_b_16_30 = 1 if stu_b_16_30a == "龙江县第一中学"
	replace stu_b_16_30 = 3 if stu_b_16_30a == "龙涤中学"
	tab stu_b_16_30,m 

	gen key_point = stu_b_16_30
	recode key_point (1=2)(2=1)(3=0)(4=.) //0:不是重点高中 ；1:市级重点 2:省级重点

	gen zhongdiangaozhong = . //重点高中 1:是  2:否
	replace zhongdiangaozhong = 1 if stu_b_16_30==1 | stu_b_16_30==2
	replace zhongdiangaozhong = 0 if stu_b_16_30==3 | stu_b_16_30==4
	label define zd 1"重点高中"0"非重点高中"
	label values zhongdiangaozhong zd
	tab zhongdiangaozhong,m

*学科门类 ——stu_major

	gen stu_major = .
	replace stu_major = 1 if regexm(stu_b_16_stumajor,"化学") == 1 | regexm(stu_b_16_stumajor,"地理科学") == 1 | regexm(stu_b_16_stumajor,"数学") == 1 | regexm(stu_b_16_stumajor,"物理") == 1  ///
	| regexm(stu_b_16_stumajor,"生物科学") == 1 
	replace stu_major = 2 if regexm(stu_b_16_stumajor,"计算机") == 1 | stu_b_16_stumajor == "食品科学与工程类" 
	replace stu_major = 3 if stu_b_16_stumajor == "中国语言文学" | regexm(stu_b_16_stumajor,"语") == 1 | regexm(stu_b_16_stumajor,"历史") == 1 | stu_b_16_stumajor == "哲学" | stu_b_16_stumajor == "外国语言文学类"  ///
	 | stu_b_16_stumajor == "广播电视编导" | stu_b_16_stumajor == "播音与主持艺术" | stu_b_16_stumajor == "新闻传播学类"  | regexm(stu_b_16_stumajor,"美术") == 1 | regexm(stu_b_16_stumajor,"舞蹈") == 1 | regexm(stu_b_16_stumajor,"音乐") == 1
	replace stu_major = 4 if stu_b_16_stumajor == "体育教育" | regexm(stu_b_16_stumajor,"公共事业管理") == 1 | stu_b_16_stumajor == "学前教育" | stu_b_16_stumajor == "工商管理类" ///
	| stu_b_16_stumajor == "心理学类" | regexm(stu_b_16_stumajor,"思想政治教育") == 1 | stu_b_16_stumajor == "教育技术学" | stu_b_16_stumajor == "旅游管理"  ///
	| stu_b_16_stumajor == "法学" | stu_b_16_stumajor == "社会学" | stu_b_16_stumajor == "经济学类" | stu_b_16_stumajor == "行政管理" | stu_b_16_stumajor == "运动训练" 
	la define stu_major 1 "理科" 2 "工科" 3 "人文" 4 "社科"
	la values stu_major stu_major
	tab stu_major,m

*是否有教师职业理想 prefer
	tab stu_b_16_51,m
	rename stu_b_16_51 norm_moti

	foreach x of numlist 1/9 {
		gen norm_r`x'=.
		replace norm_r`x'=1 if regexm(norm_moti,"`x'")==1 & stu_normal==1
		replace norm_r`x'=0 if regexm(norm_moti,"`x'")==0 & stu_normal==1
		tab norm_r`x',m
	}
	rename norm_r2 prefer 	

*是否第一志愿 zhiyuan
	tab stu_b_16_43,m
	replace stu_b_16_43=0 if stu_b_16_43==2
	rename stu_b_16_43 zhiyuan	
	
*==========*
*因变量*
*==========*	

****标准化期末英语成绩 sd_term_exam_总评成绩 
	egen sd_term_exam_总评成绩 = std(term_exam_总评成绩)

****标准化高考英语成绩 sd_gk_engscore
	rename stu_b_16_35a gk_engscore
	egen sd_gk_engscore = std(gk_engscore)
	
****教师职业选择总分
	egen stu_profession_score = rowtotal(stu_b_16_1_2 - stu_b_16_52_2)
	label var stu_profession_score "教师职业选择总分"

	*自我感知认识
	egen self_perception = rowtotal(stu_b_16_1_2 stu_b_16_2_2 stu_b_16_3_2) 
	label var  self_perception "自我感知认识"

	*内在职业价值
	egen intrinsic_career_value = rowtotal(stu_b_16_4_2 stu_b_16_5_2)
	label var intrinsic_career_value "内在职业价值"

	*再就业保障
	egen fallback_career = rowtotal(stu_b_16_50_2 stu_b_16_51_2 stu_b_16_52_2)
	label var fallback_career "再就业保障"

	*个人效用价值
	egen stu_utility_value = rowtotal(stu_b_16_6_2 stu_b_16_7_2 stu_b_16_8_2 stu_b_16_9_2 stu_b_16_10_2 stu_b_16_11_2 stu_b_16_47_2 stu_b_16_48_2 stu_b_16_49_2)
	label  var stu_utility_value "个人效用价值" 

	*社会效用价值
	egen social_utility_value = rowtotal(stu_b_16_12_2 stu_b_16_13_2 stu_b_16_14_2 stu_b_16_15_2 stu_b_16_16_2 stu_b_16_17_2 stu_b_16_18_2 stu_b_16_19_2 stu_b_16_20_2 stu_b_16_21_2 stu_b_16_22_2 stu_b_16_23_2 stu_b_16_24_2 stu_b_16_25_2 stu_b_16_26_2 stu_b_16_27_2)
	label var social_utility_value "社会效用价值"

	*任务需求
	egen task_demand = rowtotal(stu_b_16_28_2 stu_b_16_29_2 stu_b_16_30_2 stu_b_16_31_2 stu_b_16_32_2 stu_b_16_33_2)
	label var task_demand "任务需求"

	*任务回报
	egen task_return = rowtotal(stu_b_16_34_2 stu_b_16_35_2 stu_b_16_36_2 stu_b_16_37_2 stu_b_16_38_2 stu_b_16_39_2 stu_b_16_40_2 stu_b_16_41_2 stu_b_16_42_2 stu_b_16_43_2 stu_b_16_44_2 stu_b_16_45_2 stu_b_16_46_2)
	label var task_return "任务回报"
	
****SCL-90得分  m>2为检出心理状况
	egen mdepression = rowmean(stu_b_16_5_3 stu_b_16_14_3 stu_b_16_15_3 stu_b_16_20_3 stu_b_16_22_3 stu_b_16_26_3 stu_b_16_29_3 stu_b_16_30_3 stu_b_16_31_3 stu_b_16_32_3 stu_b_16_54_3 stu_b_16_71_3 stu_b_16_79_3)
//抑郁

	egen mqutihua = rowmean(stu_b_16_1_3 stu_b_16_4_3 stu_b_16_12_3 stu_b_16_27_3 stu_b_16_40_3 stu_b_16_42_3 stu_b_16_48_3 stu_b_16_49_3 stu_b_16_52_3 stu_b_16_53_3 stu_b_16_56_3 stu_b_16_58_3)
//躯体化

	egen mqiangpo = rowmean(stu_b_16_3_3 stu_b_16_9_3 stu_b_16_10_3 stu_b_16_28_3 stu_b_16_38_3 stu_b_16_45_3 stu_b_16_46_3 stu_b_16_51_3 stu_b_16_55_3 stu_b_16_65_3)
//强迫症状

	egen msensitivity = rowmean(stu_b_16_6_3 stu_b_16_21_3 stu_b_16_34_3 stu_b_16_36_3 stu_b_16_37_3 stu_b_16_41_3 stu_b_16_61_3 stu_b_16_69_3 stu_b_16_73_3)
//人际关系敏感
	
	egen manxiety = rowmean(stu_b_16_2_3 stu_b_16_17_3 stu_b_16_23_3 stu_b_16_33_3 stu_b_16_39_3 stu_b_16_57_3 stu_b_16_72_3 stu_b_16_78_3 stu_b_16_80_3 stu_b_16_86_3)
//焦虑
	
	egen mdidui = rowmean(stu_b_16_11_3 stu_b_16_24_3 stu_b_16_63_3 stu_b_16_67_3 stu_b_16_74_3 stu_b_16_81_3)
//敌对

	egen mkongbu = rowmean(stu_b_16_13_3 stu_b_16_25_3 stu_b_16_47_3 stu_b_16_50_3 stu_b_16_70_3 stu_b_16_75_3 stu_b_16_82_3)
//恐怖

	egen mpianzhi = rowmean(stu_b_16_8_3 stu_b_16_18_3 stu_b_16_43_3 stu_b_16_68_3 stu_b_16_76_3 stu_b_16_83_3) 
//偏执
	
	egen mjingshenbing = rowmean(stu_b_16_7_3 stu_b_16_16_3 stu_b_16_35_3 stu_b_16_62_3 stu_b_16_77_3 stu_b_16_84_3 stu_b_16_85_3 stu_b_16_87_3 stu_b_16_88_3 stu_b_16_90_3)
//精神病性
	
	save "$cleandir\free normal clean $date.dta",replace 
    save "$cleandir/free normal clean $date.dta",replace 
*/

*==========*
*回归结果*
*==========*	
	use "$cleandir/free normal clean $date.dta",clear
	global yvar  stu_profession_score self_perception intrinsic_career_value fallback_career stu_utility_value social_utility_value task_demand task_return
	global xvar stu_male stu_age stu_ethnic rural_hukou only_child zhongdiangaozhong SES
	
	/*删除变量中存在缺失值的样本 后期可能会用到，先不删
	foreach var of varlist stu_profession_score self_perception ///
			intrinsic_career_value fallback_career stu_utility_value ///
			social_utility_value task_demand task_return ///
			stu_male stu_age stu_ethnic rural_hukou only_child zhongdiangaozhong SES {
		drop if `var'==.
	}
	*/

//自我主导/非自我主导公费师范生对心理健康回归
	cd "$outdir"
	keep if stu_normal==1
	tokenize n1 n2 n3 n4 n5 n6 n7 n8 n9
	foreach var of varlist mdepression - mjingshenbing {
		xi:reg `var' stu_selfmotiv $xvar
			est store `1'
		xi:reg `var' stu_selfmotiv $xvar prefer
			est store `1'_p
		xi:reg `var' stu_selfmotiv $xvar prefer zhiyuan
			est store `1'_z
	macro shift
	}
	outreg2 [n1 n2 n3 n4 n5 n6 n7 n8 n9 n1_p n2_p n3_p n4_p n5_p n6_p n7_p n8_p n9_p n1_z n2_z n3_z n4_z n5_z n6_z n7_z n8_z n9_z] using reg_psy.xls, excel replace bdec(2) sdec(2)
	
//自我主导/非自我主导公费师范生对教师职业选择回归
	tokenize n1 n2 n3 n4 n5 n6 n7 n8
	foreach var of varlist stu_profession_score - task_return {
		xi:reg `var' stu_selfmotiv $xvar
			est store `1'
		xi:reg `var' stu_selfmotiv $xvar prefer
			est store `1'_p
		xi:reg `var' stu_selfmotiv $xvar prefer zhiyuan
			est store `1'_z
	macro shift
	}
	outreg2 [n1 n2 n3 n4 n5 n6 n7 n8 n1_p n2_p n3_p n4_p n5_p n6_p n7_p n8_p n1_z n2_z n3_z n4_z n5_z n6_z n7_z n8_z] using reg_prof.xls, excel replace bdec(2) sdec(2)

//自我主导/非自我主导公费师范生对英语成绩回归
	rename sd_term_exam_总评成绩 sd_term_exam_totalscore
	xi:reg sd_term_exam_totalscore stu_selfmotiv sd_gk_engscore $xvar
		est store n1
	xi:reg sd_term_exam_totalscore stu_selfmotiv sd_gk_engscore $xvar prefer
		est store n2
	xi:reg sd_term_exam_totalscore stu_selfmotiv sd_gk_engscore $xvar prefer zhiyuan
		est store n3
	outreg2 [n1 n2 n3] using reg_eng.xls, excel replace bdec(2) sdec(2) 








