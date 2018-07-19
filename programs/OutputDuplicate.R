# 確認用プログラム
# 英語病名：日本語病名が1：nのレコードを抽出
# （処理毎に）下記の手順が必要
# RStudio - Menu - Session - choose Directory
# "aronas/Projects/NMC ISR 情報システム研究室/MedDRA" を選択

# Function definition ------
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
# Constant definition ------
Sys.setenv("TZ" = "Asia/Tokyo")
# MedDRAバージョン指定
kVersion <- "V20.1"
# 入出力ファイル名
kLlt_csv <- "llt.asc"
kLlt_j_csv <- "llt_j.asc"
kLlt_j2_csv <- "llt_j2.asc"
kOutput_file <- "duplicate_llt_j2.asc"
# Llt_j2.asc列名はllt_j.ascと同一
kLlt_j_colname <- c("llt_code", "llt_kanji", "llt_jcurr", "llt_kana",
                    "llt_kana1", "llt_kana2")
kLlt_colname <- c("llt_code", "llt_name", "pt_code", "llt_whoart_code",
                  "llt_harts_code", "llt_costart_sym", "llt_icd9_code",
                  "llt_icd9cm_code", "llt_icd10_code", "llt_currency",
                  "llt_jart_code", "temp_llt")
# asciiフォルダ配下で入出力
if (!exists("input_prt_path")) {
  input_prt_path <- getwd()
}

# path setting ------
input_path <- paste0(input_prt_path, "/", kVersion, "/", "ASCII/")
temp_input_list <- list.files(input_path)
if (length(temp_input_list) == 1) {
  input_path <- paste0(input_path, "/", temp_input_list)
} else {
  input_path <- NA
}
output_path <- paste0(input_path, "/", "duplicated/")

# read csv ------
df_llt <- read.csv(paste0(input_path, "/", kLlt_csv) , as.is=T, sep="$", header=F, fileEncoding="CP932")
names(df_llt) <- kLlt_colname
df_llt_j2 <- read.csv(paste0(input_path, "/", kLlt_j2_csv) , as.is=T, sep="$", header=F, fileEncoding="CP932")
names(df_llt_j2) <- kLlt_j_colname
df_llt_j <- read.csv(paste0(input_path, "/", kLlt_j_csv) , as.is=T, sep="$", header=F, fileEncoding="CP932")
names(df_llt_j) <- kLlt_j_colname

# select data ------
# llt.ascの、llt_nameが同一のレコードを抽出
duplicated_llt_name <- ResDuplicated(df_llt, "llt_name",c("llt_code", "llt_name"))
# llt_j2.ascの、llt_kanjiが同一のレコードを抽出
duplicated_llt_j2_kanji <- ResDuplicated(df_llt_j2, "llt_kanji", c("llt_code","llt_kanji"))
# llt_j.ascの、llt_kanjiが同一のレコードを抽出
duplicated_llt_j_kanji <- ResDuplicated(df_llt_j, "llt_kanji", c("llt_code","llt_kanji"))
duplicated_llt_j_kanji<-subset(duplicated_llt_j_kanji, llt_kanji!="")
# 一つのllt_nameに対して複数のllt_kanjiがあるレコードを抽出
# 同一のllt_nameをもつllt_codeにてレコード抽出
duplicated_llt_j <- subset(df_llt_j, llt_code %in% duplicated_llt_name$llt_code)
duplicated_llt_j2 <- subset(df_llt_j2, llt_code %in% duplicated_llt_name$llt_code)

# write table ------
write.table(duplicated_llt_name, paste(output_path, "duplicated_llt_name.asc", sep="/"), append=F, quote=F,
            col.names=F, row.names=F, eol="\r\n", fileEncoding="CP932")
write.table(duplicated_llt_j2_kanji, paste(output_path, "duplicated_llt_j2_kanji.asc", sep="/"), append=F, quote=F,
            col.names=F, row.names=F, eol="\r\n", fileEncoding="CP932")
write.table(duplicated_llt_j_kanji, paste(output_path, "duplicated_llt_j_kanji.asc", sep="/"), append=F, quote=F,
            col.names=F, row.names=F, eol="\r\n", fileEncoding="CP932")
write.table(duplicated_llt_j, paste(output_path, "duplicated_llt_j.asc", sep="/"), append=F, quote=F,
            col.names=F, row.names=F, eol="\r\n", fileEncoding="CP932")
write.table(duplicated_llt_j2, paste(output_path, "duplicated_llt_j2.asc", sep="/"), append=F, quote=F,
            col.names=F, row.names=F, eol="\r\n", fileEncoding="CP932")
