# 2020.1.23 テスト
# load library ------
library("readxl")
library(dplyr)
# input csv column name
kLlt_j_colname <- c("llt_code", "llt_kanji", "llt_jcurr", "llt_kana",
                    "llt_kana1", "llt_kana2")
kLlt_colname <- c("llt_code", "llt_name", "pt_code", "llt_whoart_code",
                  "llt_harts_code", "llt_costart_sym", "llt_icd9_code",
                  "llt_icd9cm_code", "llt_icd10_code", "llt_currency",
                  "llt_jart_code", "temp_llt")
kPt_j_colname <- c("pt_code", "pt_kanji", "pt_kana", "pt_kana1", "pt_kana2")
kPt_colname <- c("pt_code", "pt_name", "null_field", "pt_soc_code",
                 "pt_whoart_code", "pt_harts_code", "pt_costart_sym",
                 "pt_icd9_code", "pt_icd9cm_code", "pt_icd10_code",
                 "pt_jart_code", "temp_pt")
kSoc_j_colname <- c("soc_code", "soc_kanji", "soc_order", "soc_kana",
                    "soc_kana1", "soc_kana2")
kSoc_colname <- c("soc_code", "soc_name", "soc_abbrev", "soc_whoart_code",
                  "soc_harts_code", "soc_costart_sym", "soc_icd9_code",
                  "soc_icd9cm_code", "soc_icd10_code", "soc_jart_code",
                  "temp_soc")
kMdhier_colname <- c("pt_code", "hlt_code", "hlgt_code", "mdhier_soc_code",
                     "pt_name", "hlt_name", "hlgt_name", "soc_name",
                     "soc_abbrev",  "null_field", "mdhier_pt_soc_code",
                     "primary_soc_fg", "temp_mdhier")
kCtcae_colname <- c("seq", "llt_code", "soc", "soc_kanji", "llt_name",
                    "llt_kanji", "Grade1", "Grade1_j", "Grade2", "Grade2_j",
                    "Grade3", "Grade3_j", "Grade4", "Grade4_j", "Grade5",
                    "Grade5_j", "AE_Term_Definition", "AE_Term_Definition_j",
                    "Navigational_Note", "Notes_on_search")

test_ctcae <- read_excel("/Volumes/Projects/NMC ISR 情報システム研究室/MedDRA/V22.1/CTCAE/CTCAEv5J_20190905_v22_1.xlsx", sheet=1, col_names=T)
test_mdhier <- read.csv("/Volumes/Projects/NMC ISR 情報システム研究室/MedDRA/V22.1/ASCII/MDRA_J221/mdhier.asc", as.is=T, sep="$", header=F, fileEncoding="CP932")
test_soc <- read.csv("/Volumes/Projects/NMC ISR 情報システム研究室/MedDRA/V22.1/ASCII/MDRA_J221/soc.asc", as.is=T, sep="$", header=F, fileEncoding="CP932")
test_soc_j <- read.csv("/Volumes/Projects/NMC ISR 情報システム研究室/MedDRA/V22.1/ASCII/MDRA_J221/soc_j.asc", as.is=T, sep="$", header=F, fileEncoding="CP932")
test_pt <- read.csv("/Volumes/Projects/NMC ISR 情報システム研究室/MedDRA/V22.1/ASCII/MDRA_J221/pt.asc", as.is=T, sep="$", header=F, fileEncoding="CP932")
test_pt_j <- read.csv("/Volumes/Projects/NMC ISR 情報システム研究室/MedDRA/V22.1/ASCII/MDRA_J221/pt_j.asc", as.is=T, sep="$", header=F, fileEncoding="CP932")
test_llt <- read.csv("/Volumes/Projects/NMC ISR 情報システム研究室/MedDRA/V22.1/ASCII/MDRA_J221/llt.asc", as.is=T, sep="$", header=F, fileEncoding="CP932")
test_llt_j <- read.csv("/Volumes/Projects/NMC ISR 情報システム研究室/MedDRA/V22.1/ASCII/MDRA_J221/llt_j.asc", as.is=T, sep="$", header=F, fileEncoding="CP932")
test_test_ctcae <- test_ctcae %>% filter(`CTCAE v5.0\r\nMedDRA \r\nv20.1 Code` == 10016558)
colnames(test_soc) <- kSoc_colname
colnames(test_soc_j) <- kSoc_j_colname
colnames(test_pt) <- kPt_colname
colnames(test_pt_j) <- kPt_j_colname
colnames(test_llt) <- kLlt_colname
colnames(test_llt_j) <- kLlt_j_colname
colnames(test_mdhier) <- kMdhier_colname
colnames(test_ctcae) <- kCtcae_colname
# 発熱
test_test_soc <- test_soc %>% filter(soc_code == 10018065)
test_test_soc_j <- test_soc_j %>% filter(soc_code == 10018065)
test_soc_merge <- inner_join(test_test_soc, test_test_soc_j, by="soc_code") %>% select(c("soc_code", "soc_name", "soc_kanji"))
test_test_pt <- test_pt %>% filter(pt_code == 10037660)
test_test_pt_j <- test_pt_j %>% filter(pt_code == 10037660)
test_pt_merge <- inner_join(test_test_pt, test_test_pt_j, by="pt_code") %>% select(c("pt_code", "pt_name", "pt_soc_code", "pt_kanji"))
test_test_llt <- test_llt %>% filter(llt_code == 10016558)
test_test_llt_j <- test_llt_j %>% filter(llt_code == 10016558)
test_llt_merge <- inner_join(test_test_llt, test_test_llt_j, by="llt_code") %>% select(c("llt_code", "llt_name", "pt_code", "llt_currency", "llt_kanji", "llt_jcurr"))
test_test_mdhier <- test_mdhier %>% filter(pt_code == 10037660)
# 出力ファイルチェック
output_txt <- read.csv("/Volumes/Projects/NMC ISR 情報システム研究室/MedDRA/V22.1/ASCII/MDRA_J221/llt_j2.asc", as.is=T, sep="$", header=F, fileEncoding="CP932")
# 出力ファイルに含まれているlltのコードを出力
target_llt <- test_llt[is.element(test_llt$llt_code, output_txt$V1),]
# pt, mdhier, socとマージ
target_llt <- target_llt %>% right_join(test_pt, ., by="pt_code")
target_llt <- target_llt %>% right_join(test_mdhier, ., by="pt_code")
target_llt <- target_llt %>% right_join(test_soc, ., by=c("soc_code"="pt_soc_code"))
# llt_currency^="Y"のレコードがないか
target_llt %>% filter(llt_currency != "Y")
# llt日本語をすべてマージ
kanji_all <- target_llt %>% left_join(test_llt_j, by="llt_code") %>% select(c("llt_code","llt_kanji","llt_jcurr","llt_kana","llt_kana1","llt_kana2"))
# 重複してる病名
duplicated_kanji_all <- kanji_all %>% group_by(llt_kanji) %>% filter(n() > 1)
# 重複してる病名でCTCAEにある
test_ctcae$int_llt_code <- as.numeric(test_ctcae$llt_code)
ctcae_duplicated_kanji <- duplicated_kanji_all %>% distinct(llt_code) %>% inner_join(test_ctcae, by=c("llt_code"="int_llt_code")) %>% select(c("llt_code", llt_kanji="llt_kanji.x"))
# 重複してる病名でCTCAEにない場合はllt_jcurr="Y"を採用
not_ctcae_duplicated_kanji <- duplicated_kanji_all %>% distinct(llt_code, .keep_all=T) %>% anti_join(test_ctcae, by=c("llt_code"="int_llt_code")) %>% filter(llt_jcurr == "Y") %>% select(c("llt_code", "llt_kanji"))
# 重複してない病名
not_duplicated_kanji_all <- kanji_all %>% group_by(llt_kanji) %>% filter(n() == 1) %>% select(c("llt_code", "llt_kanji"))
# 結合
output_all_kanji <- rbind(ctcae_duplicated_kanji, not_ctcae_duplicated_kanji, not_duplicated_kanji_all)
# llt_jから抽出して出力ファイルと比較
check_output <- subset(test_llt_j, llt_code %in% output_all_kanji$llt_code)
setequal(output_txt$V1, check_output$llt_code)
setequal(output_txt$V2, check_output$llt_kanji)
setequal(output_txt$V3, check_output$llt_jcurr)
setequal(output_txt$V4, check_output$llt_kana)
setequal(output_txt$V5, check_output$llt_kana1)
setequal(output_txt$V6, check_output$llt_kana2)
a <- output_txt$V4==check_output$llt_kana
output_txt[!(a),]
check_output[!(a),]

