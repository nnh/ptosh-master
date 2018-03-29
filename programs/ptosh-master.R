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
WriteCsv <- function(df, output_path, output_csvname){
  write.csv(df, paste(output_path, output_csvname, sep="/"), na='""', row.names=F)
  return(NA)
}
#######################
# Constant definition #
#######################
# MedDRAバージョン指定
kVersion <- "V21.0"
kOutput_foldername <- "output_ptosh_option"
input_prt_path <- "//aronas/References/NMC ISR 情報システム研究室/MedDRA"
output_prt_path <- "//aronas/Projects/NMC ISR 情報システム研究室/MedDRA"
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
input_path <- paste0(input_prt_path, "/", kVersion, "/", "ASCII")
temp_input_list <- list.files(input_path)
if (length(temp_input_list) == 1) {
  input_path <- paste0(input_path, "/", temp_input_list)
} else {
  input_path <- NA
}
output_path <- paste0(output_prt_path, "/", kVersion, "/", kOutput_foldername)
ctcae_path <- "//aronas/Projects/NMC ISR 情報システム研究室/MedDRA/V21.0/CTCAE"  # CTCAEデータ
# 出力フォルダが存在しなければ作成
if (!(file.exists(output_path))) {
  dir.create(output_path)
}
# MedDRA、CTCAEフォルダ配下のファイル存在チェック
file_existence_f <- F
if (!is.na(input_path)) {
  if (file.exists(input_path) && file.exists(ctcae_path)) {
    ctcae_file_list <- list.files(ctcae_path, full.names=T)
    # CTCAEファイルの読み込みまで成功すれば処理続行
    if (length(ctcae_file_list) == 1) {
      ctcae_df <- read_excel(ctcae_file_list[1], sheet=1, col_names=T)
      if (exists("ctcae_df")) {
        file_existence_f <- T
        # 列名に改行が入っているため再設定
        names(ctcae_df) <- kCtcae_colname
        # CTCAE 見出し行等を除去
        ctcae_df <- subset(ctcae_df, !is.na(ctcae_df$soc))
      }
    }
  }
}
if (file_existence_f == T){
  ##########
  # MDHIER #
  ##########
  # MDHIER読み込み
  mdhier_path <- paste0(input_path, "/", kMdhier_csv)
  temp_mdhier <- read.csv(mdhier_path, as.is=T, sep="$", header=F)
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
  df_llt_j <- read.csv(llt_j_path, as.is=T, sep="$", header=F)
  names(df_llt_j) <- kLlt_j_colname
  # llt_code, llt_kanjiのみ出力
  df_llt_j <- df_llt_j[c("llt_code", "llt_kanji")]
  # LLT読み込み
  llt_path <- paste0(input_path, "/", kLlt_csv)
  temp_llt <- read.csv(llt_path, as.is=T, sep="$", header=F)
  names(temp_llt) <- kLlt_colname
  # llt_code, pt_code, llt_name, llt_currencyのみ出力
  temp_llt <- temp_llt[c("llt_code", "pt_code", "llt_name", "llt_currency")]
  # llt_currency="Y"のレコードのみ対象とする
  df_llt <- subset(temp_llt, llt_currency == "Y")
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
  df_pt_j <- read.csv(pt_j_path, as.is=T, sep="$", header=F)
  names(df_pt_j) <- kPt_j_colname
  # pt_code, pt_kanjiのみ出力
  df_pt_j <- df_pt_j[c("pt_code", "pt_kanji")]
  # PT読み込み
  pt_path <- paste0(input_path, "/" ,kpt_csv)
  df_pt <- read.csv(pt_path, as.is=T, sep="$", header=F)
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
  df_soc_j <- read.csv(soc_j_path, as.is=T, sep="$", header=F)
  names(df_soc_j) <- kSoc_j_colname
  # soc_code, soc_kanjiのみ出力
  df_soc_j <- df_soc_j[c("soc_code", "soc_kanji")]
  # soc読み込み
  soc_path <- paste0(input_path, "/", kSoc_csv)
  df_soc <- read.csv(soc_path, as.is=T, sep="$", header=F)
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
  # 出力列順の変更
  df_output <- df_all_merge[c("soc_code", "pt_code", "llt_code", "soc_name", "soc_kanji", "pt_name",
                              "pt_kanji", "llt_name", "llt_kanji", "llt_currency", "pt_primary_soc_fg", "llt_primary_soc_fg")]
  ####################
  # edit output data #
  ####################
  # LLT 英語と日本語が1:nになっているレコードを抽出
  df_output_llt_name_duplicated <- ResDuplicated(df_output, "llt_kanji", c("llt_kanji", "llt_name"))
  # LLT 日本語と英語が1:nになっているレコードを抽出
  df_output_llt_kanji_duplicated <- ResDuplicated(df_output, "llt_name", c("llt_kanji", "llt_name"))
  # pt_kanji, pt_nameが重複しているレコードは削除
  temp_df_output_pt <- unique(df_output[ ,c("pt_kanji", "pt_name")])
  # PT 英語と日本語が1:nになっているレコードを抽出
  df_output_pt_name_duplicated <- ResDuplicated(temp_df_output_pt, "pt_kanji", c("pt_kanji", "pt_name"))
  # PT 日本語と英語が1:nになっているレコードを抽出
  df_output_pt_kanji_duplicated <- ResDuplicated(temp_df_output_pt, "pt_name", c("pt_kanji", "pt_name"))
  ##############
  # output csv #
  ##############
  # 全データ出力
  temp <- WriteCsv(df_output, output_path, "ptosh_option.csv")
  # llt name:kanji=1:nのデータ出力
  temp <- WriteCsv(df_output_llt_kanji_duplicated, output_path, "llt_kanji_duplicated.csv")
  # llt kanji:name=1:nのデータ出力
  temp <- WriteCsv(df_output_llt_name_duplicated, output_path, "llt_name_duplicated.csv")
  # pt name:kanji=1:nのデータ出力
  temp <- WriteCsv(df_output_pt_kanji_duplicated, output_path, "pt_kanji_duplicated.csv")
  # pt kanji:name=1:nのデータ出力
  temp <- WriteCsv(df_output_pt_name_duplicated, output_path, "pt_name_duplicated.csv")
}
