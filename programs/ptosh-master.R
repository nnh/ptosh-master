# #####################
# Function definition #
#######################
ReplaceNames <- function(df, beforenames, afternames){
  # データフレームdfの列名の、beforenamesをafternamesに変更し返す
  wknames <- names(df)
  wknames <- replace(wknames, match(beforenames, wknames), afternames)
  names(df) <- wknames
  return(df)
}
ResDuplicated <- function(df, sortkey, output_columns){
  # データフレームdfのsortkeyが重複しているレコードのみ返す
  # output_columnsで指定した列のみ
  sortlist <- order(df[ ,sortkey])
  wk_df <- df[sortlist, ]
  wk_df$check_f <- F
  # 重複チェック
  for (i in 1:(length(wk_df[ ,sortkey])-1)) {
    # 次のレコードの値が同じなら重複とし、check_f<-T
    if (wk_df[i, sortkey] == wk_df[i + 1, sortkey]) {
      wk_df[i, "check_f"] <- T
      wk_df[i + 1, "check_f"] <- T
    }
  }
  return(subset(wk_df, wk_df$check_f == T, output_columns))
}
#######################
# Constant definition #
#######################
prtpath <- "//aronas/Projects/NMC ISR 情報システム研究室/MedDRA"
output_foldername <- "/output_ptosh_option"
# 入力フォルダ指定時はkInputpathにフォルダ名をセット、NAがセットされていたらprtpath配下全て処理する
# kInputpath <- "V21.0"
kInputpath <- NA
# output csv name
kOutputCSV <- "output.csv"
# input csv name
kLlt_j_CSV <- "llt_j.asc"
kLlt_CSV <- "llt.asc"
kpt_j_CSV <- "pt_j.asc"
kpt_CSV <- "pt.asc"
kSoc_j_CSV <- "soc_j.asc"
kSoc_CSV <- "soc.asc"
kMdhier_CSV <- "mdhier.asc"
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
########################################################################################################################

# 出力フォルダが存在しなければ作成
outputpath <- paste0(prtpath, output_foldername)
if (!(file.exists(outputpath))) {
  dir.create(outputpath)
}
# フォルダ名リストを取得
wk_meddralist <- list.files(prtpath, full.names=T)
# 配下にデータがあるものをフォルダと判定
for (i in 1:length(wk_meddralist)) {
  temp_meddra <- list.files(wk_meddralist[i])
  if (length(temp_meddra) == 0) {
    wk_meddralist[i] <- NA
  }
}
meddralist <- wk_meddralist[!is.na(wk_meddralist)]
# フォルダ指定
if (!is.na(kInputpath)) {
  meddralist <- c(paste0(prtpath, "/", kInputpath))
}

for (i in 1:length(meddralist)) {
  asciipath <- meddralist[i]
  # ASCIIフォルダ下のみ処理
  wkfilelist <- list.files(asciipath, full.names=T)
  asciipath = paste0(asciipath, "/ASCII")
  if (file.exists(asciipath)) {
    # MDRA_Jxxx　フォルダ
    meddrapath <- list.files(asciipath, full.names=T)
    # 出力フォルダ切り分けのためフォルダ名を格納
    wk_output <- list.files(asciipath, full.names=F)
    ##########
    # MDHIER #
    ##########
    # MDHIER読み込み
    mdhierpath <- paste0(meddrapath, "/", kMdhier_CSV)
    wk_mdhier <- read.csv(mdhierpath, as.is=T, sep="$", header=F)
    names(wk_mdhier) <- kMdhier_colname
    # primary_soc_fg="Y"のレコードのみ対象とする
    df_mdhier <- subset(wk_mdhier, primary_soc_fg == "Y")
    # pt_code, primary_soc_fgのみ出力
    df_mdhier <- df_mdhier[c("pt_code", "primary_soc_fg")]
    #######
    # LLT #
    #######
    # LLT_J読み込み
    llt_jpath <- paste0(meddrapath, "/", kLlt_j_CSV)
    df_llt_j <- read.csv(llt_jpath, as.is=T, sep="$", header=F)
    names(df_llt_j) <- kLlt_j_colname
    # llt_code, llt_kanjiのみ出力
    df_llt_j <- df_llt_j[c("llt_code", "llt_kanji")]
    # LLT読み込み
    lltpath <- paste0(meddrapath, "/", kLlt_CSV)
    wk_llt <- read.csv(lltpath, as.is=T, sep="$", header=F)
    names(wk_llt) <- kLlt_colname
    # llt_code, pt_code, llt_name, llt_currencyのみ出力
    wk_llt <- wk_llt[c("llt_code", "pt_code", "llt_name", "llt_currency")]
    # llt_currency="Y"のレコードのみ対象とする
    df_llt <- subset(wk_llt, llt_currency == "Y")
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
    pt_jpath <- paste0(meddrapath, "/", kpt_j_CSV)
    df_pt_j <- read.csv(pt_jpath, as.is=T, sep="$", header=F)
    names(df_pt_j) <- kPt_j_colname
    # pt_code, pt_kanjiのみ出力
    df_pt_j <- df_pt_j[c("pt_code", "pt_kanji")]
    # PT読み込み
    ptpath <- paste0(meddrapath, "/" ,kpt_CSV)
    df_pt <- read.csv(ptpath, as.is=T, sep="$", header=F)
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
    soc_jpath <- paste0(meddrapath, "/", kSoc_j_CSV)
    df_soc_j <- read.csv(soc_jpath, as.is=T, sep="$", header=F)
    names(df_soc_j) <- kSoc_j_colname
    # soc_code, soc_kanjiのみ出力
    df_soc_j <- df_soc_j[c("soc_code", "soc_kanji")]
    # soc読み込み
    socpath <- paste0(meddrapath, "/", kSoc_CSV)
    df_soc <- read.csv(socpath, as.is=T, sep="$", header=F)
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
    wk_df_output_pt <- unique(df_output[ ,c("pt_kanji", "pt_name")])
    # PT 英語と日本語が1:nになっているレコードを抽出
    df_output_pt_name_duplicated <- ResDuplicated(wk_df_output_pt, "pt_kanji", c("pt_kanji", "pt_name"))
    # PT 日本語と英語が1:nになっているレコードを抽出
    df_output_pt_kanji_duplicated <- ResDuplicated(wk_df_output_pt, "pt_name", c("pt_kanji", "pt_name"))
    ##############
    # output csv #
    ##############
    # フォルダが無ければ作成
    outputvarpath <- paste0(outputpath, "/", wk_output)
    if (!(file.exists(outputvarpath))) {
      dir.create(outputvarpath)
    }
    # 全データ出力
    write.csv(df_output, paste(outputvarpath, "ptosh_option.csv", sep="/"), na='""', row.names=F)
    # llt name:kanji=1:n
    write.csv(df_output_llt_kanji_duplicated, paste(outputvarpath, "llt_kanji_duplicated.csv", sep="/"), na='""', row.names=F)
    # llt kanji:name=1:n
    write.csv(df_output_llt_name_duplicated, paste(outputvarpath, "llt_name_duplicated.csv", sep="/"), na='""', row.names=F)
    # llt name:kanji=1:n
    write.csv(df_output_pt_kanji_duplicated, paste(outputvarpath, "pt_kanji_duplicated.csv", sep="/"), na='""', row.names=F)
    # pt kanji:name=1:n
    write.csv(df_output_pt_name_duplicated, paste(outputvarpath, "pt_name_duplicated.csv", sep="/"), na='""', row.names=F)
    }
}
