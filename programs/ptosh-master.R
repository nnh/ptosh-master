# readxlのインストールが必要
# install.packages('readxl')
library("readxl")
#######################
# Function definition #
#######################
ReplaceNames <- function(df, before_names, after_names){
  # データフレームdfの列名の、before_namesをafter_namesに変更し返す
  temp_names <- replace(names(df), match(before_names, names(df)), after_names)
  names(df) <- temp_names
  return(df)
}
ResDuplicated <- function(df, sortkey, output_columns){
  # データフレームdfの、sortkey列のデータが重複しているレコードのoutput_columns列を返す
  sortlist <- order(df[ ,sortkey])
  temp_df <- df[sortlist, ]
  temp_df$check_f <- F
  # 重複チェック
  for (i in 1:(length(temp_df[ ,sortkey])-1)) {
    # 次のレコードの値が同じなら重複とし、check_fをTにする
    if (temp_df[i, sortkey] == temp_df[i + 1, sortkey]) {
      temp_df[i, "check_f"] <- T
      temp_df[i + 1, "check_f"] <- T
    }
  }
  return(subset(temp_df, temp_df$check_f == T, output_columns))
}
SortDF <- function(df, sortkey1, sortkey2){
  # データフレームdfをsortkey1昇順,sortkey2降順でソートして返す
  sortlist <- order(df[ ,sortkey1], df[ ,sortkey2], decreasing=T)
  df_sort <- df[sortlist, ]
  return(df_sort)
}
#######################
# Constant definition #
#######################
Sys.setenv("TZ" = "Asia/Tokyo")
# MedDRAバージョン指定
kVersion <- "V21.0"
kOutput_foldername <- "output_ptosh_option"
input_prt_path <- "/Volumes/References/NMC ISR 情報システム研究室/MedDRA"
output_prt_path <- "/Volumes/Projects/NMC ISR 情報システム研究室/MedDRA"
# input csv name
kLlt_j_csv <- "llt_j.asc"
kLlt_csv <- "llt.asc"
kpt_j_csv <- "pt_j.asc"
kpt_csv <- "pt.asc"
kSoc_j_csv <- "soc_j.asc"
kSoc_csv <- "soc.asc"
kMdhier_csv <- "mdhier.asc"
# input csv column name
kLlt_j_colname <- c("llt_code", "llt_kanji", "llt_jcurr", "llt_kana", "llt_kana1", "llt_kana2")
kLlt_colname <- c("llt_code", "llt_name", "pt_code", "llt_whoart_code",
                  "llt_harts_code", "llt_costart_sym", "llt_icd9_code",
                  "llt_icd9cm_code", "llt_icd10_code", "llt_currency", "llt_jart_code", "temp_llt")
kPt_j_colname <- c("pt_code", "pt_kanji", "pt_kana", "pt_kana1", "pt_kana2")
kPt_colname <- c("pt_code", "pt_name", "null_field", "pt_soc_code", "pt_whoart_code",
                 "pt_harts_code", "pt_costart_sym", "pt_icd9_code", "pt_icd9cm_code",
                 "pt_icd10_code", "pt_jart_code", "temp_pt")
kSoc_j_colname <- c("soc_code", "soc_kanji", "soc_order", "soc_kana", "soc_kana1", "soc_kana2")
kSoc_colname <- c("soc_code", "soc_name", "soc_abbrev", "soc_whoart_code", "soc_harts_code",
                  "soc_costart_sym", "soc_icd9_code", "soc_icd9cm_code", "soc_icd10_code", "soc_jart_code", "temp_soc")
kMdhier_colname <- c("pt_code", "hlt_code", "hlgt_code", "mdhier_soc_code", "pt_name", "hlt_name",
                     "hlgt_name", "soc_name", "soc_abbrev", "null_field", "mdhier_pt_soc_code", "primary_soc_fg", "temp_mdhier")
kCtcae_colname <- c("seq", "llt_code", "soc", "soc_kanji", "llt_name", "llt_kanji", "Grade1", "Grade1_j",
                    "Grade2", "Grade2_j", "Grade3", "Grade3_j", "Grade4", "Grade4_j", "Grade5", "Grade5_j",
                    "AE_Term_Definition", "AE_Term_Definition_j")
########################################################################################################################
# パス設定
# MedDRA\Vxx.x\ASCII\MDRA_Jxxx(xxxはバージョン毎に異なる)に入力ファイルが格納されている
input_path <- paste0(input_prt_path, "/", kVersion, "/", "ASCII/")
temp_input_list <- list.files(input_path)
if (length(temp_input_list) == 1) {
  input_path <- paste0(input_path, "/", temp_input_list)
} else {
  input_path <- NA
}
output_path <- paste0(output_prt_path, "/", kVersion, "/", kOutput_foldername)
ctcae_path <- "/Volumes/Projects/NMC ISR 情報システム研究室/MedDRA/V21.0/CTCAE"  # CTCAEデータ
# 出力フォルダが存在しなければ作成
if (file.exists(output_path) == F) {
  dir.create(output_path)
}
# MedDRA、CTCAEフォルダ配下のファイル存在チェック
file_existence_f <- F
if (!is.na(input_path)) {
  if (file.exists(input_path) && file.exists(ctcae_path)) {
    ctcae_file_list <- list.files(ctcae_path, full.names=T)
    # CTCAEファイルの読み込みまで成功すれば処理続行
    if (length(ctcae_file_list) == 1) {
      df_ctcae <- read_excel(ctcae_file_list[1], sheet=1, col_names=T)
      if (exists("df_ctcae")) {
        file_existence_f <- T
        # 列名に改行が入っているため再設定
        names(df_ctcae) <- kCtcae_colname
        # CTCAE 見出し行等を除去
        df_ctcae <- subset(df_ctcae, !is.na(df_ctcae$soc))
        # コード順にソート
        sortlist <- order(df_ctcae$llt_code)
        df_ctcae <- df_ctcae[sortlist, ]
      }
    }
  }
}
if (file_existence_f == T) {
  ##########
  # MDHIER #
  ##########
  # MDHIER読み込み
  mdhier_path <- paste0(input_path, "/", kMdhier_csv)
  temp_mdhier <- read.csv(mdhier_path, as.is=T, sep="$", header=F, fileEncoding="CP932")
  names(temp_mdhier) <- kMdhier_colname
  # primary_soc_fg="Y"のレコードのみ対象とする
  df_mdhier <- subset(temp_mdhier, primary_soc_fg == "Y")
  # pt_code, primary_soc_fgのみ出力
  df_mdhier <- df_mdhier[c("pt_code", "primary_soc_fg")]
  #######
  # LLT #
  #######
  # LLT_J読み込み
  llt_j_path <- paste0(input_path, "/", kLlt_j_csv)
  df_llt_j <- read.csv(llt_j_path, as.is=T, sep="$", header=F, fileEncoding="CP932")
  names(df_llt_j) <- kLlt_j_colname
  # llt_code, llt_kanji, llt_jcurrのみ出力
  df_llt_j <- df_llt_j[c("llt_code", "llt_kanji", "llt_jcurr")]
  # LLT読み込み
  llt_path <- paste0(input_path, "/", kLlt_csv)
  temp_llt <- read.csv(llt_path, as.is=T, sep="$", header=F, fileEncoding="CP932")
  names(temp_llt) <- kLlt_colname
  # CTCAEとマージ CTCAEに存在しないレコードはseqに-1をセット
  df_llt_ctcae_merge <- merge(temp_llt, df_ctcae[ ,c("llt_code", "seq")], by="llt_code", all.x=T)
  df_llt_ctcae_merge$seq <- ifelse(is.na(df_llt_ctcae_merge$seq), -1, df_llt_ctcae_merge$seq)
  # llt_code, pt_code, llt_name, llt_currency, seqのみ出力
  df_llt_ctcae_merge <- df_llt_ctcae_merge[c("llt_code", "pt_code", "llt_name", "llt_currency", "seq")]
  # llt_currency="Y"のレコードのみ対象とする
  df_llt <- subset(df_llt_ctcae_merge, llt_currency == "Y")
  # LLTとLLT_Jをllt_codeでマージ
  df_llt_merge <- merge(df_llt, df_llt_j, by="llt_code", all.x=T)
  # hierarchyとpt_codeでマージ
  df_llt_mdhier_merge <- merge(df_llt_merge, df_mdhier, by="pt_code", all.x=T)
  # 列名primary_soc_fg->llt_primary_soc_fgに変更する
  df_llt_mdhier_merge <- ReplaceNames(df_llt_mdhier_merge, "primary_soc_fg", "llt_primary_soc_fg")
  ######
  # PT #
  ######
  # PT_J読み込み
  pt_j_path <- paste0(input_path, "/", kpt_j_csv)
  df_pt_j <- read.csv(pt_j_path, as.is=T, sep="$", header=F, fileEncoding="CP932")
  names(df_pt_j) <- kPt_j_colname
  # pt_code, pt_kanjiのみ出力
  df_pt_j <- df_pt_j[c("pt_code", "pt_kanji")]
  # PT読み込み
  pt_path <- paste0(input_path, "/" ,kpt_csv)
  df_pt <- read.csv(pt_path, as.is=T, sep="$", header=F, fileEncoding="CP932")
  names(df_pt) <- kPt_colname
  # pt_code, pt_soc_code, pt_nameのみ出力
  df_pt <- df_pt[c("pt_code", "pt_soc_code", "pt_name")]
  # PTとPT_Jをpt_codeでマージ
  df_pt_merge <- merge(df_pt, df_pt_j, by="pt_code", all.x=T)
  # hierarchyとpt_codeでマージ
  df_pt_mdhier_merge <- merge(df_pt_merge, df_mdhier, by="pt_code", all.x=T)
  # 列名primary_soc_fg->pt_primary_soc_fgに変更する
  df_pt_mdhier_merge <- ReplaceNames(df_pt_mdhier_merge, "primary_soc_fg", "pt_primary_soc_fg")
  #######
  # soc #
  #######
  # soc_J読み込み
  soc_j_path <- paste0(input_path, "/", kSoc_j_csv)
  df_soc_j <- read.csv(soc_j_path, as.is=T, sep="$", header=F, fileEncoding="CP932")
  names(df_soc_j) <- kSoc_j_colname
  # soc_code, soc_kanjiのみ出力
  df_soc_j <- df_soc_j[c("soc_code", "soc_kanji")]
  # soc読み込み
  soc_path <- paste0(input_path, "/", kSoc_csv)
  df_soc <- read.csv(soc_path, as.is=T, sep="$", header=F, fileEncoding="CP932")
  names(df_soc) <- kSoc_colname
  # soc_code, soc_nameのみ出力
  df_soc <- df_soc[c("soc_code", "soc_name")]
  # socとsoc_Jをsoc_codeでマージ
  df_soc_merge <- merge(df_soc, df_soc_j, by="soc_code", all.x=T)
  #######
  # all #
  #######
  # LLTとPTをPTCODEでマージし、さらにSOCとSOCCODEでマージする
  df_llt_pt_merge <- merge(df_llt_mdhier_merge, df_pt_mdhier_merge, by="pt_code", all.x=T)
  df_all_merge <- merge(df_llt_pt_merge, df_soc_merge, by.x="pt_soc_code", by.y="soc_code", all.x=T)
  # 列名pt_soc_code->soc_codeに変更する
  df_all_merge <- ReplaceNames(df_all_merge, "pt_soc_code", "soc_code")
  # 日本語重複病名の削除
  # うつ病->Depression, Depression mental, Depressive illnessのように日本語と英語が1:nになっている病名への対応
  # CTCAEに存在する病名は、そのLLT_CODEのみ出力対象とする
  # 上記に当てはまらないものについては日本語カレンシーフラグがYのレコードを出力する
  # llt_kanji昇順, seq降順でソート
  df_sort_all_merge <- SortDF(df_all_merge, "llt_kanji", "seq")
  save_llt_kanji <- ""
  df_sort_all_merge$delete_f <- F
  for (i in 1:length(df_sort_all_merge$llt_code)) {
    # 同一日本語病名でseq>0のレコードがある場合、seq=-1のレコードは削除する
    if (df_sort_all_merge[i, "seq"] > 0) {
      # llt_kanjiを退避
      save_llt_kanji <- df_sort_all_merge[i, "llt_kanji"]
    } else {
      if (save_llt_kanji == df_sort_all_merge[i, "llt_kanji"]){
        df_sort_all_merge[i, "delete_f"] <- T
      }
    }
  }
  df_all_merge_ctcae <- subset(df_sort_all_merge, delete_f == F)
  # llt_kanji昇順, llt_jcurr降順でソート
  save_llt_kanji <- ""
  df_sort_all_merge_ctcae <- SortDF(df_all_merge_ctcae, "llt_kanji", "llt_jcurr")
  for (i in 1:length(df_sort_all_merge_ctcae$llt_code)) {
    # 同一日本語病名の場合日本語カレンシーフラグがNのレコードを削除する
    if (df_sort_all_merge_ctcae[i, "llt_jcurr"] == "Y") {
      save_llt_kanji <- df_sort_all_merge_ctcae[i, "llt_kanji"]
    } else {
      if (save_llt_kanji == df_sort_all_merge_ctcae[i, "llt_kanji"]) {
        df_sort_all_merge_ctcae[i, "delete_f"] <- T
      }
    }
  }
  df_output_all_merge <- subset(df_sort_all_merge_ctcae, delete_f == F)
  # Ptosh option用出力データ
  df_output_all_merge$llt_label <- paste0(df_output_all_merge$llt_kanji, "; ", df_output_all_merge$llt_name)
  # 出力列順の変更
  df_MedDRA <- df_output_all_merge[c("soc_code", "soc_name", "soc_kanji", "pt_code", "pt_name",
                              "pt_kanji", "llt_code", "llt_name", "llt_kanji", "llt_label", "pt_primary_soc_fg",
                              "llt_primary_soc_fg", "llt_currency", "llt_jcurr")]
  write.csv(df_MedDRA, paste(output_path, "MedDRA.csv", sep="/"), na='""', row.names=F)
}
