# pip install pymupdf   |   python prepare_docs.py ./folder_pdf ./dokumen_privat
import fitz, os, sys
M={"BNSP_SAYA":"bnsp","freecompress-TOEFL_TERBARU_587":"toefl","IJAZAH_S1-BAGAS_FATHURRAHMAN":"ijazah_s1","TRANSKIP_NILAI_STRATA_pdf":"transkrip_s1",
"Sertifikat_Akreditasi_BAN-PT_APT_Universitas_BSI__Unggul__140625-140630":"akreditasi_pt",
"Sertifikat_Akreditasi_FKLTS_LAMINFOKOM_Teknologi_Informasi__S1__UBSI_Unggul_020824-020829_":"akreditasi_prodi",
"EKTM":"ektm","IJAZAH_SMK_BAGAS_FATHURRAHMAN":"ijazah_smk","TRANSKIP_NILAI_UAN_SMK":"transkrip_smk",
"Surat_Keterangan_Selesai_PKL_Magang_a_n_Bagas_Faturrahman":"pkl","PAS_FOTO_Background_Biru":"pasfoto","skck_2026":"skck",
"SKBN":"bebas_narkoba","IDENTITAS_KTP-BAGAS_FATHURRAHMAN":"ktp","KK_DAN_AKTE":"kk_akte","BPJS":"bpjs"}
src,out=sys.argv[1],sys.argv[2]
for f,i in M.items():
    p=os.path.join(src,f+".pdf")
    if not os.path.exists(p): print("lewati:",f); continue
    os.makedirs(os.path.join(out,i),exist_ok=True)
    for n,pg in enumerate(fitz.open(p),1):
        z=1100/pg.rect.width   # resolusi sengaja dibatasi: cukup dibaca, kurang berguna untuk disalahgunakan
        pg.get_pixmap(matrix=fitz.Matrix(z,z)).save(os.path.join(out,i,f"p{n:02d}.jpg"),jpg_quality=70)
    print("ok:",i)
