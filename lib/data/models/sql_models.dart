/// GENERATED CODE - DO NOT MODIFY BY HAND
class SqlModels {}

class Trans {
  final String? transId;
  final String? transparentId;
  final String? transparentsumberId;
  final String? transparentuangmukaId;
  final String? transparentpesananId;
  final String? transparentbiayaId;
  final String? transparentkoreksiIjpId;
  final String? transparentcrossbussinessId;
  final String? masteraccountId;
  final String? masterpartnerId;
  final String? masterpartneralamatId;
  final String? masterpartnerkontakId;
  final String? masterpartnertelpId;
  final String? masterterminId;
  final String? masterexpedisiId;
  final String? masterreasonId;
  final String? masterkursId;
  final String? masterwarehouseId;
  final String? masterstoreId;
  final String? masterwarehousetujuanId;
  final String? masterstoretujuanId;
  final String? masterfixassetId;
  final String? fakturlineId;
  final String? mastermejaId;
  final String? masterlayananId;
  final String? mastermesinId;
  final String? masterdeviceId;
  final String? masterprefixId;
  final String? masteruserId;
  final String? masterbussinesscrossbussinessId;
  final String? masteremployeeId;
  final String? masterbussinessId;
  final String? transText;
  final int? transType;
  final int? transTerminhari;
  final int? transJumlahtamu;
  final int? transMaxdurasi;
  final double? transNilaikurs;
  final int? transEntrydate;
  final int? transTglnota;
  final int? transTgljatem;
  final int? transTglkirim;
  final int? transMulai;
  final String? transKeterangan;
  final String? transNomornota;
  final String? transNomorresi;
  final String? transNomorgiro;
  final String? transNomormigrasireferensi;
  final String? transNomormigrasireferensi2;
  final int? transGirojatem;
  final int? transGirocair;
  final double? transDiscgroupinput;
  final String? transIsdiscgrouppersen;
  final double? transDiscgroup;
  final String? transIsincludevat;
  final String? transIsdiscpersen;
  final String? transIsallocation;
  final String? transIsallowadditem;
  final String? transIsjumlahkan;
  final String? transIspriceperpiece;
  final String? transIslogomodel;
  final String? transTerupload;
  final int? transFakturdatestart;
  final int? transFakturdateend;
  final String? transFakturawal;
  final String? transFakturakhir;
  final String? transFakturnomorawal;
  final String? transPayroll;

  Trans({
    this.transId,
    this.transparentId,
    this.transparentsumberId,
    this.transparentuangmukaId,
    this.transparentpesananId,
    this.transparentbiayaId,
    this.transparentkoreksiIjpId,
    this.transparentcrossbussinessId,
    this.masteraccountId,
    this.masterpartnerId,
    this.masterpartneralamatId,
    this.masterpartnerkontakId,
    this.masterpartnertelpId,
    this.masterterminId,
    this.masterexpedisiId,
    this.masterreasonId,
    this.masterkursId,
    this.masterwarehouseId,
    this.masterstoreId,
    this.masterwarehousetujuanId,
    this.masterstoretujuanId,
    this.masterfixassetId,
    this.fakturlineId,
    this.mastermejaId,
    this.masterlayananId,
    this.mastermesinId,
    this.masterdeviceId,
    this.masterprefixId,
    this.masteruserId,
    this.masterbussinesscrossbussinessId,
    this.masteremployeeId,
    this.masterbussinessId,
    this.transText,
    this.transType,
    this.transTerminhari,
    this.transJumlahtamu,
    this.transMaxdurasi,
    this.transNilaikurs,
    this.transEntrydate,
    this.transTglnota,
    this.transTgljatem,
    this.transTglkirim,
    this.transMulai,
    this.transKeterangan,
    this.transNomornota,
    this.transNomorresi,
    this.transNomorgiro,
    this.transNomormigrasireferensi,
    this.transNomormigrasireferensi2,
    this.transGirojatem,
    this.transGirocair,
    this.transDiscgroupinput,
    this.transIsdiscgrouppersen,
    this.transDiscgroup,
    this.transIsincludevat,
    this.transIsdiscpersen,
    this.transIsallocation,
    this.transIsallowadditem,
    this.transIsjumlahkan,
    this.transIspriceperpiece,
    this.transIslogomodel,
    this.transTerupload,
    this.transFakturdatestart,
    this.transFakturdateend,
    this.transFakturawal,
    this.transFakturakhir,
    this.transFakturnomorawal,
    this.transPayroll,
  });

  factory Trans.fromJson(Map<String, dynamic> json) {
    return Trans(
      transId: json["trans_id"]?.toString(),
      transparentId: json["transparent_id"]?.toString(),
      transparentsumberId: json["transparentsumber_id"]?.toString(),
      transparentuangmukaId: json["transparentuangmuka_id"]?.toString(),
      transparentpesananId: json["transparentpesanan_id"]?.toString(),
      transparentbiayaId: json["transparentbiaya_id"]?.toString(),
      transparentkoreksiIjpId: json["transparentkoreksi_ijp_id"]?.toString(),
      transparentcrossbussinessId: json["transparentcrossbussiness_id"]?.toString(),
      masteraccountId: json["masteraccount_id"]?.toString(),
      masterpartnerId: json["masterpartner_id"]?.toString(),
      masterpartneralamatId: json["masterpartneralamat_id"]?.toString(),
      masterpartnerkontakId: json["masterpartnerkontak_id"]?.toString(),
      masterpartnertelpId: json["masterpartnertelp_id"]?.toString(),
      masterterminId: json["mastertermin_id"]?.toString(),
      masterexpedisiId: json["masterexpedisi_id"]?.toString(),
      masterreasonId: json["masterreason_id"]?.toString(),
      masterkursId: json["masterkurs_id"]?.toString(),
      masterwarehouseId: json["masterwarehouse_id"]?.toString(),
      masterstoreId: json["masterstore_id"]?.toString(),
      masterwarehousetujuanId: json["masterwarehousetujuan_id"]?.toString(),
      masterstoretujuanId: json["masterstoretujuan_id"]?.toString(),
      masterfixassetId: json["masterfixasset_id"]?.toString(),
      fakturlineId: json["fakturline_id"]?.toString(),
      mastermejaId: json["mastermeja_id"]?.toString(),
      masterlayananId: json["masterlayanan_id"]?.toString(),
      mastermesinId: json["mastermesin_id"]?.toString(),
      masterdeviceId: json["masterdevice_id"]?.toString(),
      masterprefixId: json["masterprefix_id"]?.toString(),
      masteruserId: json["masteruser_id"]?.toString(),
      masterbussinesscrossbussinessId: json["masterbussinesscrossbussiness_id"]?.toString(),
      masteremployeeId: json["masteremployee_id"]?.toString(),
      masterbussinessId: json["masterbussiness_id"]?.toString(),
      transText: json["trans_text"]?.toString(),
      transType: json["trans_type"] != null ? int.tryParse(json["trans_type"].toString()) : null,
      transTerminhari: json["trans_terminhari"] != null ? int.tryParse(json["trans_terminhari"].toString()) : null,
      transJumlahtamu: json["trans_jumlahtamu"] != null ? int.tryParse(json["trans_jumlahtamu"].toString()) : null,
      transMaxdurasi: json["trans_maxdurasi"] != null ? int.tryParse(json["trans_maxdurasi"].toString()) : null,
      transNilaikurs: json["trans_nilaikurs"] != null ? double.tryParse(json["trans_nilaikurs"].toString()) : null,
      transEntrydate: json["trans_entrydate"] != null ? int.tryParse(json["trans_entrydate"].toString()) : null,
      transTglnota: json["trans_tglnota"] != null ? int.tryParse(json["trans_tglnota"].toString()) : null,
      transTgljatem: json["trans_tgljatem"] != null ? int.tryParse(json["trans_tgljatem"].toString()) : null,
      transTglkirim: json["trans_tglkirim"] != null ? int.tryParse(json["trans_tglkirim"].toString()) : null,
      transMulai: json["trans_mulai"] != null ? int.tryParse(json["trans_mulai"].toString()) : null,
      transKeterangan: json["trans_keterangan"]?.toString(),
      transNomornota: json["trans_nomornota"]?.toString(),
      transNomorresi: json["trans_nomorresi"]?.toString(),
      transNomorgiro: json["trans_nomorgiro"]?.toString(),
      transNomormigrasireferensi: json["trans_nomormigrasireferensi"]?.toString(),
      transNomormigrasireferensi2: json["trans_nomormigrasireferensi2"]?.toString(),
      transGirojatem: json["trans_girojatem"] != null ? int.tryParse(json["trans_girojatem"].toString()) : null,
      transGirocair: json["trans_girocair"] != null ? int.tryParse(json["trans_girocair"].toString()) : null,
      transDiscgroupinput: json["trans_discgroupinput"] != null ? double.tryParse(json["trans_discgroupinput"].toString()) : null,
      transIsdiscgrouppersen: json["trans_isdiscgrouppersen"]?.toString(),
      transDiscgroup: json["trans_discgroup"] != null ? double.tryParse(json["trans_discgroup"].toString()) : null,
      transIsincludevat: json["trans_isincludevat"]?.toString(),
      transIsdiscpersen: json["trans_isdiscpersen"]?.toString(),
      transIsallocation: json["trans_isallocation"]?.toString(),
      transIsallowadditem: json["trans_isallowadditem"]?.toString(),
      transIsjumlahkan: json["trans_isjumlahkan"]?.toString(),
      transIspriceperpiece: json["trans_ispriceperpiece"]?.toString(),
      transIslogomodel: json["trans_islogomodel"]?.toString(),
      transTerupload: json["trans_terupload"]?.toString(),
      transFakturdatestart: json["trans_fakturdatestart"] != null ? int.tryParse(json["trans_fakturdatestart"].toString()) : null,
      transFakturdateend: json["trans_fakturdateend"] != null ? int.tryParse(json["trans_fakturdateend"].toString()) : null,
      transFakturawal: json["trans_fakturawal"]?.toString(),
      transFakturakhir: json["trans_fakturakhir"]?.toString(),
      transFakturnomorawal: json["trans_fakturnomorawal"]?.toString(),
      transPayroll: json["trans_payroll"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "trans_id": transId,
      "transparent_id": transparentId,
      "transparentsumber_id": transparentsumberId,
      "transparentuangmuka_id": transparentuangmukaId,
      "transparentpesanan_id": transparentpesananId,
      "transparentbiaya_id": transparentbiayaId,
      "transparentkoreksi_ijp_id": transparentkoreksiIjpId,
      "transparentcrossbussiness_id": transparentcrossbussinessId,
      "masteraccount_id": masteraccountId,
      "masterpartner_id": masterpartnerId,
      "masterpartneralamat_id": masterpartneralamatId,
      "masterpartnerkontak_id": masterpartnerkontakId,
      "masterpartnertelp_id": masterpartnertelpId,
      "mastertermin_id": masterterminId,
      "masterexpedisi_id": masterexpedisiId,
      "masterreason_id": masterreasonId,
      "masterkurs_id": masterkursId,
      "masterwarehouse_id": masterwarehouseId,
      "masterstore_id": masterstoreId,
      "masterwarehousetujuan_id": masterwarehousetujuanId,
      "masterstoretujuan_id": masterstoretujuanId,
      "masterfixasset_id": masterfixassetId,
      "fakturline_id": fakturlineId,
      "mastermeja_id": mastermejaId,
      "masterlayanan_id": masterlayananId,
      "mastermesin_id": mastermesinId,
      "masterdevice_id": masterdeviceId,
      "masterprefix_id": masterprefixId,
      "masteruser_id": masteruserId,
      "masterbussinesscrossbussiness_id": masterbussinesscrossbussinessId,
      "masteremployee_id": masteremployeeId,
      "masterbussiness_id": masterbussinessId,
      "trans_text": transText,
      "trans_type": transType,
      "trans_terminhari": transTerminhari,
      "trans_jumlahtamu": transJumlahtamu,
      "trans_maxdurasi": transMaxdurasi,
      "trans_nilaikurs": transNilaikurs,
      "trans_entrydate": transEntrydate,
      "trans_tglnota": transTglnota,
      "trans_tgljatem": transTgljatem,
      "trans_tglkirim": transTglkirim,
      "trans_mulai": transMulai,
      "trans_keterangan": transKeterangan,
      "trans_nomornota": transNomornota,
      "trans_nomorresi": transNomorresi,
      "trans_nomorgiro": transNomorgiro,
      "trans_nomormigrasireferensi": transNomormigrasireferensi,
      "trans_nomormigrasireferensi2": transNomormigrasireferensi2,
      "trans_girojatem": transGirojatem,
      "trans_girocair": transGirocair,
      "trans_discgroupinput": transDiscgroupinput,
      "trans_isdiscgrouppersen": transIsdiscgrouppersen,
      "trans_discgroup": transDiscgroup,
      "trans_isincludevat": transIsincludevat,
      "trans_isdiscpersen": transIsdiscpersen,
      "trans_isallocation": transIsallocation,
      "trans_isallowadditem": transIsallowadditem,
      "trans_isjumlahkan": transIsjumlahkan,
      "trans_ispriceperpiece": transIspriceperpiece,
      "trans_islogomodel": transIslogomodel,
      "trans_terupload": transTerupload,
      "trans_fakturdatestart": transFakturdatestart,
      "trans_fakturdateend": transFakturdateend,
      "trans_fakturawal": transFakturawal,
      "trans_fakturakhir": transFakturakhir,
      "trans_fakturnomorawal": transFakturnomorawal,
      "trans_payroll": transPayroll,
    };
  }
}

class Transline {
  final String? translineId;
  final String? translinesecondId;
  final String? translineparentId;
  final String? translineparentreturId;
  final String? translineparentsumberId;
  final String? translinepackingsumberId;
  final String? translinepackingindukId;
  final String? translineparentpesananId;
  final String? transId;
  final String? transparentId;
  final String? transparentdaftarmuatId;
  final String? masterexpedisidaftarmuatId;
  final String? masterdriverdaftarmuatId;
  final String? masteraccountId;
  final String? masteritemuomId;
  final String? masteritemuomflyId;
  final String? masteruomflyId;
  final String? masteruomfly02Id;
  final String? masteruomfly03Id;
  final String? masterwarehouseId;
  final String? masterstoreId;
  final String? mastertaxId;
  final String? masterkemasanId;
  final String? priceId;
  final String? mastermesinId;
  final String? masterentitypromoId;
  final String? masterpromoId;
  final String? masterkomponenId;
  final String? masterbussinessId;
  final String? translinescrapId;
  final String? translinescrapfinalId;
  final String? translinescrapunixId;
  final String? translineinId;
  final String? translineinunixId;
  final String? translineoldId;
  final int? translineNourut;
  final int? translineNourutfly;
  final int? translineNourutparent;
  final String? translineKeterangan;
  final String? translineKeterangan02;
  final int? translineEntrydate;
  final int? translineEntrydate02;
  final double? translineTaxrate;
  final double? translineDistribusi;
  final int? translineVector;
  final double? translineConvertionqty;
  final double? translineConvertionqtyfly;
  final double? translineConvertionqtyfly02;
  final double? translineQtyinput;
  final double? translineQtyinputfly;
  final double? translineQtyinputfly02;
  final double? translineQtyinputfly03;
  final double? translineQtyinputfly04;
  final double? translineQtybom;
  final double? translineTara;
  final double? translineTarafly;
  final double? translineQty;
  final double? translineMinqtyused;
  final double? translineMaxqtyused;
  final double? translineMinqtysell;
  final double? translineMaxqtysell;
  final String? translineIspersenpriceinput;
  final double? translinePriceinput;
  final double? translinePriceinputfly;
  final double? translinePriceinputfly2;
  final double? translinePersencardcharges;
  final double? translineCardchargesvalue;
  final double? translinePrice;
  final double? translinePricefly;
  final double? translinePricefly2;
  final double? translineDiscinput;
  final double? translineDiscinput02;
  final double? translineDiscinput03;
  final double? translineDiscinput04;
  final double? translineDiscinput05;
  final double? translineDiscinputfly;
  final double? translineDiscinputother;
  final double? translineDisc;
  final double? translineDisc02;
  final double? translineDisc03;
  final double? translineDisc04;
  final double? translineDisc05;
  final double? translineDiscgroupline;
  final double? translineDiscgrouplinesync;
  final double? translineDiscgrouplinevalue;
  final double? translineTotaldiscvalue;
  final double? translineVat;
  final double? translineVatvalue;
  final double? translineNetraw;
  final double? translineNet;
  final double? translineNetvalue;
  final double? translineTax;
  final double? translineTaxvalue;
  final double? translineSejmcpesan;
  final double? translineSejmcproses;
  final double? translineSejmcfinal;
  final double? translineSejczpesan;
  final double? translineSejczproses;
  final double? translineSejczfinal;
  final int? translineUncertainty;
  final int? translineKelipatanpoin;
  final double? translinePoin;
  final double? translinePoin02;
  final double? translinePoinvalue;
  final String? translineFakturnomor;
  final String? translineIscardcharges;
  final String? translineIsunappliedpayment;
  final String? translineIsuangmuka;
  final String? translineIspayment;
  final String? translineIsothertax;

  Transline({
    this.translineId,
    this.translinesecondId,
    this.translineparentId,
    this.translineparentreturId,
    this.translineparentsumberId,
    this.translinepackingsumberId,
    this.translinepackingindukId,
    this.translineparentpesananId,
    this.transId,
    this.transparentId,
    this.transparentdaftarmuatId,
    this.masterexpedisidaftarmuatId,
    this.masterdriverdaftarmuatId,
    this.masteraccountId,
    this.masteritemuomId,
    this.masteritemuomflyId,
    this.masteruomflyId,
    this.masteruomfly02Id,
    this.masteruomfly03Id,
    this.masterwarehouseId,
    this.masterstoreId,
    this.mastertaxId,
    this.masterkemasanId,
    this.priceId,
    this.mastermesinId,
    this.masterentitypromoId,
    this.masterpromoId,
    this.masterkomponenId,
    this.masterbussinessId,
    this.translinescrapId,
    this.translinescrapfinalId,
    this.translinescrapunixId,
    this.translineinId,
    this.translineinunixId,
    this.translineoldId,
    this.translineNourut,
    this.translineNourutfly,
    this.translineNourutparent,
    this.translineKeterangan,
    this.translineKeterangan02,
    this.translineEntrydate,
    this.translineEntrydate02,
    this.translineTaxrate,
    this.translineDistribusi,
    this.translineVector,
    this.translineConvertionqty,
    this.translineConvertionqtyfly,
    this.translineConvertionqtyfly02,
    this.translineQtyinput,
    this.translineQtyinputfly,
    this.translineQtyinputfly02,
    this.translineQtyinputfly03,
    this.translineQtyinputfly04,
    this.translineQtybom,
    this.translineTara,
    this.translineTarafly,
    this.translineQty,
    this.translineMinqtyused,
    this.translineMaxqtyused,
    this.translineMinqtysell,
    this.translineMaxqtysell,
    this.translineIspersenpriceinput,
    this.translinePriceinput,
    this.translinePriceinputfly,
    this.translinePriceinputfly2,
    this.translinePersencardcharges,
    this.translineCardchargesvalue,
    this.translinePrice,
    this.translinePricefly,
    this.translinePricefly2,
    this.translineDiscinput,
    this.translineDiscinput02,
    this.translineDiscinput03,
    this.translineDiscinput04,
    this.translineDiscinput05,
    this.translineDiscinputfly,
    this.translineDiscinputother,
    this.translineDisc,
    this.translineDisc02,
    this.translineDisc03,
    this.translineDisc04,
    this.translineDisc05,
    this.translineDiscgroupline,
    this.translineDiscgrouplinesync,
    this.translineDiscgrouplinevalue,
    this.translineTotaldiscvalue,
    this.translineVat,
    this.translineVatvalue,
    this.translineNetraw,
    this.translineNet,
    this.translineNetvalue,
    this.translineTax,
    this.translineTaxvalue,
    this.translineSejmcpesan,
    this.translineSejmcproses,
    this.translineSejmcfinal,
    this.translineSejczpesan,
    this.translineSejczproses,
    this.translineSejczfinal,
    this.translineUncertainty,
    this.translineKelipatanpoin,
    this.translinePoin,
    this.translinePoin02,
    this.translinePoinvalue,
    this.translineFakturnomor,
    this.translineIscardcharges,
    this.translineIsunappliedpayment,
    this.translineIsuangmuka,
    this.translineIspayment,
    this.translineIsothertax,
  });

  factory Transline.fromJson(Map<String, dynamic> json) {
    return Transline(
      translineId: json["transline_id"]?.toString(),
      translinesecondId: json["translinesecond_id"]?.toString(),
      translineparentId: json["translineparent_id"]?.toString(),
      translineparentreturId: json["translineparentretur_id"]?.toString(),
      translineparentsumberId: json["translineparentsumber_id"]?.toString(),
      translinepackingsumberId: json["translinepackingsumber_id"]?.toString(),
      translinepackingindukId: json["translinepackinginduk_id"]?.toString(),
      translineparentpesananId: json["translineparentpesanan_id"]?.toString(),
      transId: json["trans_id"]?.toString(),
      transparentId: json["transparent_id"]?.toString(),
      transparentdaftarmuatId: json["transparentdaftarmuat_id"]?.toString(),
      masterexpedisidaftarmuatId: json["masterexpedisidaftarmuat_id"]?.toString(),
      masterdriverdaftarmuatId: json["masterdriverdaftarmuat_id"]?.toString(),
      masteraccountId: json["masteraccount_id"]?.toString(),
      masteritemuomId: json["masteritemuom_id"]?.toString(),
      masteritemuomflyId: json["masteritemuomfly_id"]?.toString(),
      masteruomflyId: json["masteruomfly_id"]?.toString(),
      masteruomfly02Id: json["masteruomfly02_id"]?.toString(),
      masteruomfly03Id: json["masteruomfly03_id"]?.toString(),
      masterwarehouseId: json["masterwarehouse_id"]?.toString(),
      masterstoreId: json["masterstore_id"]?.toString(),
      mastertaxId: json["mastertax_id"]?.toString(),
      masterkemasanId: json["masterkemasan_id"]?.toString(),
      priceId: json["price_id"]?.toString(),
      mastermesinId: json["mastermesin_id"]?.toString(),
      masterentitypromoId: json["masterentitypromo_id"]?.toString(),
      masterpromoId: json["masterpromo_id"]?.toString(),
      masterkomponenId: json["masterkomponen_id"]?.toString(),
      masterbussinessId: json["masterbussiness_id"]?.toString(),
      translinescrapId: json["translinescrap_id"]?.toString(),
      translinescrapfinalId: json["translinescrapfinal_id"]?.toString(),
      translinescrapunixId: json["translinescrapunix_id"]?.toString(),
      translineinId: json["translinein_id"]?.toString(),
      translineinunixId: json["translineinunix_id"]?.toString(),
      translineoldId: json["translineold_id"]?.toString(),
      translineNourut: json["transline_nourut"] != null ? int.tryParse(json["transline_nourut"].toString()) : null,
      translineNourutfly: json["transline_nourutfly"] != null ? int.tryParse(json["transline_nourutfly"].toString()) : null,
      translineNourutparent: json["transline_nourutparent"] != null ? int.tryParse(json["transline_nourutparent"].toString()) : null,
      translineKeterangan: json["transline_keterangan"]?.toString(),
      translineKeterangan02: json["transline_keterangan02"]?.toString(),
      translineEntrydate: json["transline_entrydate"] != null ? int.tryParse(json["transline_entrydate"].toString()) : null,
      translineEntrydate02: json["transline_entrydate02"] != null ? int.tryParse(json["transline_entrydate02"].toString()) : null,
      translineTaxrate: json["transline_taxrate"] != null ? double.tryParse(json["transline_taxrate"].toString()) : null,
      translineDistribusi: json["transline_distribusi"] != null ? double.tryParse(json["transline_distribusi"].toString()) : null,
      translineVector: json["transline_vector"] != null ? int.tryParse(json["transline_vector"].toString()) : null,
      translineConvertionqty: json["transline_convertionqty"] != null ? double.tryParse(json["transline_convertionqty"].toString()) : null,
      translineConvertionqtyfly: json["transline_convertionqtyfly"] != null ? double.tryParse(json["transline_convertionqtyfly"].toString()) : null,
      translineConvertionqtyfly02: json["transline_convertionqtyfly02"] != null ? double.tryParse(json["transline_convertionqtyfly02"].toString()) : null,
      translineQtyinput: json["transline_qtyinput"] != null ? double.tryParse(json["transline_qtyinput"].toString()) : null,
      translineQtyinputfly: json["transline_qtyinputfly"] != null ? double.tryParse(json["transline_qtyinputfly"].toString()) : null,
      translineQtyinputfly02: json["transline_qtyinputfly02"] != null ? double.tryParse(json["transline_qtyinputfly02"].toString()) : null,
      translineQtyinputfly03: json["transline_qtyinputfly03"] != null ? double.tryParse(json["transline_qtyinputfly03"].toString()) : null,
      translineQtyinputfly04: json["transline_qtyinputfly04"] != null ? double.tryParse(json["transline_qtyinputfly04"].toString()) : null,
      translineQtybom: json["transline_qtybom"] != null ? double.tryParse(json["transline_qtybom"].toString()) : null,
      translineTara: json["transline_tara"] != null ? double.tryParse(json["transline_tara"].toString()) : null,
      translineTarafly: json["transline_tarafly"] != null ? double.tryParse(json["transline_tarafly"].toString()) : null,
      translineQty: json["transline_qty"] != null ? double.tryParse(json["transline_qty"].toString()) : null,
      translineMinqtyused: json["transline_minqtyused"] != null ? double.tryParse(json["transline_minqtyused"].toString()) : null,
      translineMaxqtyused: json["transline_maxqtyused"] != null ? double.tryParse(json["transline_maxqtyused"].toString()) : null,
      translineMinqtysell: json["transline_minqtysell"] != null ? double.tryParse(json["transline_minqtysell"].toString()) : null,
      translineMaxqtysell: json["transline_maxqtysell"] != null ? double.tryParse(json["transline_maxqtysell"].toString()) : null,
      translineIspersenpriceinput: json["transline_ispersenpriceinput"]?.toString(),
      translinePriceinput: json["transline_priceinput"] != null ? double.tryParse(json["transline_priceinput"].toString()) : null,
      translinePriceinputfly: json["transline_priceinputfly"] != null ? double.tryParse(json["transline_priceinputfly"].toString()) : null,
      translinePriceinputfly2: json["transline_priceinputfly2"] != null ? double.tryParse(json["transline_priceinputfly2"].toString()) : null,
      translinePersencardcharges: json["transline_persencardcharges"] != null ? double.tryParse(json["transline_persencardcharges"].toString()) : null,
      translineCardchargesvalue: json["transline_cardchargesvalue"] != null ? double.tryParse(json["transline_cardchargesvalue"].toString()) : null,
      translinePrice: json["transline_price"] != null ? double.tryParse(json["transline_price"].toString()) : null,
      translinePricefly: json["transline_pricefly"] != null ? double.tryParse(json["transline_pricefly"].toString()) : null,
      translinePricefly2: json["transline_pricefly2"] != null ? double.tryParse(json["transline_pricefly2"].toString()) : null,
      translineDiscinput: json["transline_discinput"] != null ? double.tryParse(json["transline_discinput"].toString()) : null,
      translineDiscinput02: json["transline_discinput02"] != null ? double.tryParse(json["transline_discinput02"].toString()) : null,
      translineDiscinput03: json["transline_discinput03"] != null ? double.tryParse(json["transline_discinput03"].toString()) : null,
      translineDiscinput04: json["transline_discinput04"] != null ? double.tryParse(json["transline_discinput04"].toString()) : null,
      translineDiscinput05: json["transline_discinput05"] != null ? double.tryParse(json["transline_discinput05"].toString()) : null,
      translineDiscinputfly: json["transline_discinputfly"] != null ? double.tryParse(json["transline_discinputfly"].toString()) : null,
      translineDiscinputother: json["transline_discinputother"] != null ? double.tryParse(json["transline_discinputother"].toString()) : null,
      translineDisc: json["transline_disc"] != null ? double.tryParse(json["transline_disc"].toString()) : null,
      translineDisc02: json["transline_disc02"] != null ? double.tryParse(json["transline_disc02"].toString()) : null,
      translineDisc03: json["transline_disc03"] != null ? double.tryParse(json["transline_disc03"].toString()) : null,
      translineDisc04: json["transline_disc04"] != null ? double.tryParse(json["transline_disc04"].toString()) : null,
      translineDisc05: json["transline_disc05"] != null ? double.tryParse(json["transline_disc05"].toString()) : null,
      translineDiscgroupline: json["transline_discgroupline"] != null ? double.tryParse(json["transline_discgroupline"].toString()) : null,
      translineDiscgrouplinesync: json["transline_discgrouplinesync"] != null ? double.tryParse(json["transline_discgrouplinesync"].toString()) : null,
      translineDiscgrouplinevalue: json["transline_discgrouplinevalue"] != null ? double.tryParse(json["transline_discgrouplinevalue"].toString()) : null,
      translineTotaldiscvalue: json["transline_totaldiscvalue"] != null ? double.tryParse(json["transline_totaldiscvalue"].toString()) : null,
      translineVat: json["transline_vat"] != null ? double.tryParse(json["transline_vat"].toString()) : null,
      translineVatvalue: json["transline_vatvalue"] != null ? double.tryParse(json["transline_vatvalue"].toString()) : null,
      translineNetraw: json["transline_netraw"] != null ? double.tryParse(json["transline_netraw"].toString()) : null,
      translineNet: json["transline_net"] != null ? double.tryParse(json["transline_net"].toString()) : null,
      translineNetvalue: json["transline_netvalue"] != null ? double.tryParse(json["transline_netvalue"].toString()) : null,
      translineTax: json["transline_tax"] != null ? double.tryParse(json["transline_tax"].toString()) : null,
      translineTaxvalue: json["transline_taxvalue"] != null ? double.tryParse(json["transline_taxvalue"].toString()) : null,
      translineSejmcpesan: json["transline_sejmcpesan"] != null ? double.tryParse(json["transline_sejmcpesan"].toString()) : null,
      translineSejmcproses: json["transline_sejmcproses"] != null ? double.tryParse(json["transline_sejmcproses"].toString()) : null,
      translineSejmcfinal: json["transline_sejmcfinal"] != null ? double.tryParse(json["transline_sejmcfinal"].toString()) : null,
      translineSejczpesan: json["transline_sejczpesan"] != null ? double.tryParse(json["transline_sejczpesan"].toString()) : null,
      translineSejczproses: json["transline_sejczproses"] != null ? double.tryParse(json["transline_sejczproses"].toString()) : null,
      translineSejczfinal: json["transline_sejczfinal"] != null ? double.tryParse(json["transline_sejczfinal"].toString()) : null,
      translineUncertainty: json["transline_uncertainty"] != null ? int.tryParse(json["transline_uncertainty"].toString()) : null,
      translineKelipatanpoin: json["transline_kelipatanpoin"] != null ? int.tryParse(json["transline_kelipatanpoin"].toString()) : null,
      translinePoin: json["transline_poin"] != null ? double.tryParse(json["transline_poin"].toString()) : null,
      translinePoin02: json["transline_poin02"] != null ? double.tryParse(json["transline_poin02"].toString()) : null,
      translinePoinvalue: json["transline_poinvalue"] != null ? double.tryParse(json["transline_poinvalue"].toString()) : null,
      translineFakturnomor: json["transline_fakturnomor"]?.toString(),
      translineIscardcharges: json["transline_iscardcharges"]?.toString(),
      translineIsunappliedpayment: json["transline_isunappliedpayment"]?.toString(),
      translineIsuangmuka: json["transline_isuangmuka"]?.toString(),
      translineIspayment: json["transline_ispayment"]?.toString(),
      translineIsothertax: json["transline_isothertax"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "transline_id": translineId,
      "translinesecond_id": translinesecondId,
      "translineparent_id": translineparentId,
      "translineparentretur_id": translineparentreturId,
      "translineparentsumber_id": translineparentsumberId,
      "translinepackingsumber_id": translinepackingsumberId,
      "translinepackinginduk_id": translinepackingindukId,
      "translineparentpesanan_id": translineparentpesananId,
      "trans_id": transId,
      "transparent_id": transparentId,
      "transparentdaftarmuat_id": transparentdaftarmuatId,
      "masterexpedisidaftarmuat_id": masterexpedisidaftarmuatId,
      "masterdriverdaftarmuat_id": masterdriverdaftarmuatId,
      "masteraccount_id": masteraccountId,
      "masteritemuom_id": masteritemuomId,
      "masteritemuomfly_id": masteritemuomflyId,
      "masteruomfly_id": masteruomflyId,
      "masteruomfly02_id": masteruomfly02Id,
      "masteruomfly03_id": masteruomfly03Id,
      "masterwarehouse_id": masterwarehouseId,
      "masterstore_id": masterstoreId,
      "mastertax_id": mastertaxId,
      "masterkemasan_id": masterkemasanId,
      "price_id": priceId,
      "mastermesin_id": mastermesinId,
      "masterentitypromo_id": masterentitypromoId,
      "masterpromo_id": masterpromoId,
      "masterkomponen_id": masterkomponenId,
      "masterbussiness_id": masterbussinessId,
      "translinescrap_id": translinescrapId,
      "translinescrapfinal_id": translinescrapfinalId,
      "translinescrapunix_id": translinescrapunixId,
      "translinein_id": translineinId,
      "translineinunix_id": translineinunixId,
      "translineold_id": translineoldId,
      "transline_nourut": translineNourut,
      "transline_nourutfly": translineNourutfly,
      "transline_nourutparent": translineNourutparent,
      "transline_keterangan": translineKeterangan,
      "transline_keterangan02": translineKeterangan02,
      "transline_entrydate": translineEntrydate,
      "transline_entrydate02": translineEntrydate02,
      "transline_taxrate": translineTaxrate,
      "transline_distribusi": translineDistribusi,
      "transline_vector": translineVector,
      "transline_convertionqty": translineConvertionqty,
      "transline_convertionqtyfly": translineConvertionqtyfly,
      "transline_convertionqtyfly02": translineConvertionqtyfly02,
      "transline_qtyinput": translineQtyinput,
      "transline_qtyinputfly": translineQtyinputfly,
      "transline_qtyinputfly02": translineQtyinputfly02,
      "transline_qtyinputfly03": translineQtyinputfly03,
      "transline_qtyinputfly04": translineQtyinputfly04,
      "transline_qtybom": translineQtybom,
      "transline_tara": translineTara,
      "transline_tarafly": translineTarafly,
      "transline_qty": translineQty,
      "transline_minqtyused": translineMinqtyused,
      "transline_maxqtyused": translineMaxqtyused,
      "transline_minqtysell": translineMinqtysell,
      "transline_maxqtysell": translineMaxqtysell,
      "transline_ispersenpriceinput": translineIspersenpriceinput,
      "transline_priceinput": translinePriceinput,
      "transline_priceinputfly": translinePriceinputfly,
      "transline_priceinputfly2": translinePriceinputfly2,
      "transline_persencardcharges": translinePersencardcharges,
      "transline_cardchargesvalue": translineCardchargesvalue,
      "transline_price": translinePrice,
      "transline_pricefly": translinePricefly,
      "transline_pricefly2": translinePricefly2,
      "transline_discinput": translineDiscinput,
      "transline_discinput02": translineDiscinput02,
      "transline_discinput03": translineDiscinput03,
      "transline_discinput04": translineDiscinput04,
      "transline_discinput05": translineDiscinput05,
      "transline_discinputfly": translineDiscinputfly,
      "transline_discinputother": translineDiscinputother,
      "transline_disc": translineDisc,
      "transline_disc02": translineDisc02,
      "transline_disc03": translineDisc03,
      "transline_disc04": translineDisc04,
      "transline_disc05": translineDisc05,
      "transline_discgroupline": translineDiscgroupline,
      "transline_discgrouplinesync": translineDiscgrouplinesync,
      "transline_discgrouplinevalue": translineDiscgrouplinevalue,
      "transline_totaldiscvalue": translineTotaldiscvalue,
      "transline_vat": translineVat,
      "transline_vatvalue": translineVatvalue,
      "transline_netraw": translineNetraw,
      "transline_net": translineNet,
      "transline_netvalue": translineNetvalue,
      "transline_tax": translineTax,
      "transline_taxvalue": translineTaxvalue,
      "transline_sejmcpesan": translineSejmcpesan,
      "transline_sejmcproses": translineSejmcproses,
      "transline_sejmcfinal": translineSejmcfinal,
      "transline_sejczpesan": translineSejczpesan,
      "transline_sejczproses": translineSejczproses,
      "transline_sejczfinal": translineSejczfinal,
      "transline_uncertainty": translineUncertainty,
      "transline_kelipatanpoin": translineKelipatanpoin,
      "transline_poin": translinePoin,
      "transline_poin02": translinePoin02,
      "transline_poinvalue": translinePoinvalue,
      "transline_fakturnomor": translineFakturnomor,
      "transline_iscardcharges": translineIscardcharges,
      "transline_isunappliedpayment": translineIsunappliedpayment,
      "transline_isuangmuka": translineIsuangmuka,
      "transline_ispayment": translineIspayment,
      "transline_isothertax": translineIsothertax,
    };
  }
}

class Masterentity {
  final String? masterentityId;
  final String? masterentityparentId;
  final String? masterpartnerId;
  final String? masterpartnerjualId;
  final String? masterstoreId;
  final String? masterpartnercategoryId;
  final String? masteraccountsubclassId;
  final String? masteritemtypeId;
  final String? masteritemcategoryId;
  final String? masterassetcategoryId;
  final String? mastertaxId;
  final String? mastertaxjualId;
  final String? masteruomId;
  final String? masterbrandId;
  final String? masterkursId;
  final String? masterterminId;
  final String? masterterminjualId;
  final String? masteraccountId;
  final String? masteraccountjualId;
  final String? masteraccountItemcategorypersediaanId;
  final String? masteraccountItemcategoryhppId;
  final String? masteraccountItemcategoryjualId;
  final String? masteraccountItemcategoryjualreturId;
  final String? masteraccountItemcategoryjualdiscId;
  final String? masteraccountItemcategoryppnmasukId;
  final String? masteraccountItemcategoryppnkeluarId;
  final String? masteraccountFixassetId;
  final String? masteraccountFixassetexpenseId;
  final String? masteraccountFixassetakumulasiId;
  final String? masteraccountFixassetkeuntunganId;
  final String? masteraccountFixassetkerugianId;
  final String? masteraccountFixassetperawatanId;
  final String? masteraccountFixassetppnmasukanId;
  final String? masteraccountFixassetppnkeluaranId;
  final String? masterusercategoryId;
  final String? masterareaproduksiId;
  final String? masterprinterId;
  final String? masteruserId;
  final String? masterdepartmentId;
  final String? masterjabatanId;
  final String? masterbussinessId;
  final int? masterentityType;
  final String? masterentityDescription;
  final String? masterentityAlias;
  final String? masterentityAliasinternal;
  final String? masterentityAliasproduksi;
  final String? masterentityAliasexternal;
  final String? masterentityKeterangan;
  final String? masterentityNamaprinter;
  final String? masterentityFixmodepenyusutan;
  final double? masterentityNilai;
  final double? masterentityNilai02;
  final double? masterentityCardchargespersen;
  final String? masterentityPricebookmodeharga;
  final String? masterentityPricebookisdefault;
  final int? masterentityPricebookstart;
  final int? masterentityPricebookend;
  final String? masterentityPricebookwaktustart;
  final String? masterentityPricebookwaktuend;
  final String? masterentityPricebookispersen;
  final String? masterentityPromotype;
  final String? masterentityIspromomultiply;
  final String? masterentityIspromotunggal;
  final String? masterentityIspromovoucher;
  final double? masterentityPromosyarat;
  final double? masterentityPromomendapatkan;
  final int? masterentityPromoquota;
  final String? masterentityPromoisgiftvoucher;
  final String? masterentityPromorelasiandor;
  final int? masterentityPromobranddiscline;
  final int? masterentityPromobrandminimitem;
  final int? masterentityCountsum;
  final int? masterentityLimitqtynotaunpaid;
  final int? masterentityLimitmaxhari;
  final String? masterentityStartstring;
  final String? masterentityEndstring;
  final String? masterentityIptimbangan;
  final int? masterentityPorttimbangan;
  final String? masterentityBarcode;
  final double? masterentityStockmin;
  final double? masterentityStockmax;
  final double? masterentityQtysellmin;
  final double? masterentityQtysellmax;
  final int? masterentityFixtglperolehan;
  final int? masterentityFixtglmulaisusut;
  final int? masterentityFixtglterjual;
  final double? masterentityFixtaxrate;
  final double? masterentityFixtaxratejual;
  final double? masterentityPersentasesusut;
  final int? masterentityFixdurasipenyusutan;
  final double? masterentityFixratepenyusutan;
  final double? masterentityFixsusutvalue;
  final double? masterentityFixtaxvalue;
  final double? masterentityFixtaxvaluejual;
  final double? masterentityFixsalvagevalue;
  final String? masterentityIsbatchserial;
  final String? masterentityIstara;
  final String? masterentityIssupplier;
  final String? masterentityIscustomer;
  final String? masterentityIsemployee;
  final String? masterentityIssales;
  final String? mastereneityIsgrader;
  final String? masterentityIspecahan;
  final String? masterentityIsincludeppn;
  final String? masterentityIssuperuser;
  final String? masterentityIsgudangsum;
  final String? masterentityIsstock;
  final String? masterentityIssold;
  final String? masterentityIspurch;
  final String? masterentityIsinassembly;
  final String? masterentityIsoutassembly;
  final String? masterentityIssaldoawal;
  final String? masterentityIsadjustment;
  final String? masterentityPajaknomornpwp;
  final String? masterentityPajaknamanpwp;
  final String? masterentityPajakalamatnpwp;
  final String? masterentityPajakblok;
  final String? masterentityPajaknomor;
  final String? masterentityPajakrt;
  final String? masterentityPajakrw;
  final String? masterentityPajakkecamatan;
  final String? masterentityPajakkelurahan;
  final String? masterentityPajakkabupaten;
  final String? masterentityPajakprovinsi;
  final String? masterentityPajakkodepos;
  final String? masterentityBuyertin;
  final String? masterentityBuyerdocument;
  final String? masterentityBuyerdocumentnumber;
  final String? masterentityBuyeridtku;
  final String? masterentityCatatan;
  final String? masterentityPajakopsifaktur;
  final int? masterentityModelabel;
  final String? masterentityStatus;

  Masterentity({
    this.masterentityId,
    this.masterentityparentId,
    this.masterpartnerId,
    this.masterpartnerjualId,
    this.masterstoreId,
    this.masterpartnercategoryId,
    this.masteraccountsubclassId,
    this.masteritemtypeId,
    this.masteritemcategoryId,
    this.masterassetcategoryId,
    this.mastertaxId,
    this.mastertaxjualId,
    this.masteruomId,
    this.masterbrandId,
    this.masterkursId,
    this.masterterminId,
    this.masterterminjualId,
    this.masteraccountId,
    this.masteraccountjualId,
    this.masteraccountItemcategorypersediaanId,
    this.masteraccountItemcategoryhppId,
    this.masteraccountItemcategoryjualId,
    this.masteraccountItemcategoryjualreturId,
    this.masteraccountItemcategoryjualdiscId,
    this.masteraccountItemcategoryppnmasukId,
    this.masteraccountItemcategoryppnkeluarId,
    this.masteraccountFixassetId,
    this.masteraccountFixassetexpenseId,
    this.masteraccountFixassetakumulasiId,
    this.masteraccountFixassetkeuntunganId,
    this.masteraccountFixassetkerugianId,
    this.masteraccountFixassetperawatanId,
    this.masteraccountFixassetppnmasukanId,
    this.masteraccountFixassetppnkeluaranId,
    this.masterusercategoryId,
    this.masterareaproduksiId,
    this.masterprinterId,
    this.masteruserId,
    this.masterdepartmentId,
    this.masterjabatanId,
    this.masterbussinessId,
    this.masterentityType,
    this.masterentityDescription,
    this.masterentityAlias,
    this.masterentityAliasinternal,
    this.masterentityAliasproduksi,
    this.masterentityAliasexternal,
    this.masterentityKeterangan,
    this.masterentityNamaprinter,
    this.masterentityFixmodepenyusutan,
    this.masterentityNilai,
    this.masterentityNilai02,
    this.masterentityCardchargespersen,
    this.masterentityPricebookmodeharga,
    this.masterentityPricebookisdefault,
    this.masterentityPricebookstart,
    this.masterentityPricebookend,
    this.masterentityPricebookwaktustart,
    this.masterentityPricebookwaktuend,
    this.masterentityPricebookispersen,
    this.masterentityPromotype,
    this.masterentityIspromomultiply,
    this.masterentityIspromotunggal,
    this.masterentityIspromovoucher,
    this.masterentityPromosyarat,
    this.masterentityPromomendapatkan,
    this.masterentityPromoquota,
    this.masterentityPromoisgiftvoucher,
    this.masterentityPromorelasiandor,
    this.masterentityPromobranddiscline,
    this.masterentityPromobrandminimitem,
    this.masterentityCountsum,
    this.masterentityLimitqtynotaunpaid,
    this.masterentityLimitmaxhari,
    this.masterentityStartstring,
    this.masterentityEndstring,
    this.masterentityIptimbangan,
    this.masterentityPorttimbangan,
    this.masterentityBarcode,
    this.masterentityStockmin,
    this.masterentityStockmax,
    this.masterentityQtysellmin,
    this.masterentityQtysellmax,
    this.masterentityFixtglperolehan,
    this.masterentityFixtglmulaisusut,
    this.masterentityFixtglterjual,
    this.masterentityFixtaxrate,
    this.masterentityFixtaxratejual,
    this.masterentityPersentasesusut,
    this.masterentityFixdurasipenyusutan,
    this.masterentityFixratepenyusutan,
    this.masterentityFixsusutvalue,
    this.masterentityFixtaxvalue,
    this.masterentityFixtaxvaluejual,
    this.masterentityFixsalvagevalue,
    this.masterentityIsbatchserial,
    this.masterentityIstara,
    this.masterentityIssupplier,
    this.masterentityIscustomer,
    this.masterentityIsemployee,
    this.masterentityIssales,
    this.mastereneityIsgrader,
    this.masterentityIspecahan,
    this.masterentityIsincludeppn,
    this.masterentityIssuperuser,
    this.masterentityIsgudangsum,
    this.masterentityIsstock,
    this.masterentityIssold,
    this.masterentityIspurch,
    this.masterentityIsinassembly,
    this.masterentityIsoutassembly,
    this.masterentityIssaldoawal,
    this.masterentityIsadjustment,
    this.masterentityPajaknomornpwp,
    this.masterentityPajaknamanpwp,
    this.masterentityPajakalamatnpwp,
    this.masterentityPajakblok,
    this.masterentityPajaknomor,
    this.masterentityPajakrt,
    this.masterentityPajakrw,
    this.masterentityPajakkecamatan,
    this.masterentityPajakkelurahan,
    this.masterentityPajakkabupaten,
    this.masterentityPajakprovinsi,
    this.masterentityPajakkodepos,
    this.masterentityBuyertin,
    this.masterentityBuyerdocument,
    this.masterentityBuyerdocumentnumber,
    this.masterentityBuyeridtku,
    this.masterentityCatatan,
    this.masterentityPajakopsifaktur,
    this.masterentityModelabel,
    this.masterentityStatus,
  });

  factory Masterentity.fromJson(Map<String, dynamic> json) {
    return Masterentity(
      masterentityId: json["masterentity_id"]?.toString(),
      masterentityparentId: json["masterentityparent_id"]?.toString(),
      masterpartnerId: json["masterpartner_id"]?.toString(),
      masterpartnerjualId: json["masterpartnerjual_id"]?.toString(),
      masterstoreId: json["masterstore_id"]?.toString(),
      masterpartnercategoryId: json["masterpartnercategory_id"]?.toString(),
      masteraccountsubclassId: json["masteraccountsubclass_id"]?.toString(),
      masteritemtypeId: json["masteritemtype_id"]?.toString(),
      masteritemcategoryId: json["masteritemcategory_id"]?.toString(),
      masterassetcategoryId: json["masterassetcategory_id"]?.toString(),
      mastertaxId: json["mastertax_id"]?.toString(),
      mastertaxjualId: json["mastertaxjual_id"]?.toString(),
      masteruomId: json["masteruom_id"]?.toString(),
      masterbrandId: json["masterbrand_id"]?.toString(),
      masterkursId: json["masterkurs_id"]?.toString(),
      masterterminId: json["mastertermin_id"]?.toString(),
      masterterminjualId: json["masterterminjual_id"]?.toString(),
      masteraccountId: json["masteraccount_id"]?.toString(),
      masteraccountjualId: json["masteraccountjual_id"]?.toString(),
      masteraccountItemcategorypersediaanId: json["masteraccount_itemcategorypersediaan_id"]?.toString(),
      masteraccountItemcategoryhppId: json["masteraccount_itemcategoryhpp_id"]?.toString(),
      masteraccountItemcategoryjualId: json["masteraccount_itemcategoryjual_id"]?.toString(),
      masteraccountItemcategoryjualreturId: json["masteraccount_itemcategoryjualretur_id"]?.toString(),
      masteraccountItemcategoryjualdiscId: json["masteraccount_itemcategoryjualdisc_id"]?.toString(),
      masteraccountItemcategoryppnmasukId: json["masteraccount_itemcategoryppnmasuk_id"]?.toString(),
      masteraccountItemcategoryppnkeluarId: json["masteraccount_itemcategoryppnkeluar_id"]?.toString(),
      masteraccountFixassetId: json["masteraccount_fixasset_id"]?.toString(),
      masteraccountFixassetexpenseId: json["masteraccount_fixassetexpense_id"]?.toString(),
      masteraccountFixassetakumulasiId: json["masteraccount_fixassetakumulasi_id"]?.toString(),
      masteraccountFixassetkeuntunganId: json["masteraccount_fixassetkeuntungan_id"]?.toString(),
      masteraccountFixassetkerugianId: json["masteraccount_fixassetkerugian_id"]?.toString(),
      masteraccountFixassetperawatanId: json["masteraccount_fixassetperawatan_id"]?.toString(),
      masteraccountFixassetppnmasukanId: json["masteraccount_fixassetppnmasukan_id"]?.toString(),
      masteraccountFixassetppnkeluaranId: json["masteraccount_fixassetppnkeluaran_id"]?.toString(),
      masterusercategoryId: json["masterusercategory_id"]?.toString(),
      masterareaproduksiId: json["masterareaproduksi_id"]?.toString(),
      masterprinterId: json["masterprinter_id"]?.toString(),
      masteruserId: json["masteruser_id"]?.toString(),
      masterdepartmentId: json["masterdepartment_id"]?.toString(),
      masterjabatanId: json["masterjabatan_id"]?.toString(),
      masterbussinessId: json["masterbussiness_id"]?.toString(),
      masterentityType: json["masterentity_type"] != null ? int.tryParse(json["masterentity_type"].toString()) : null,
      masterentityDescription: json["masterentity_description"]?.toString(),
      masterentityAlias: json["masterentity_alias"]?.toString(),
      masterentityAliasinternal: json["masterentity_aliasinternal"]?.toString(),
      masterentityAliasproduksi: json["masterentity_aliasproduksi"]?.toString(),
      masterentityAliasexternal: json["masterentity_aliasexternal"]?.toString(),
      masterentityKeterangan: json["masterentity_keterangan"]?.toString(),
      masterentityNamaprinter: json["masterentity_namaprinter"]?.toString(),
      masterentityFixmodepenyusutan: json["masterentity_fixmodepenyusutan"]?.toString(),
      masterentityNilai: json["masterentity_nilai"] != null ? double.tryParse(json["masterentity_nilai"].toString()) : null,
      masterentityNilai02: json["masterentity_nilai02"] != null ? double.tryParse(json["masterentity_nilai02"].toString()) : null,
      masterentityCardchargespersen: json["masterentity_cardchargespersen"] != null ? double.tryParse(json["masterentity_cardchargespersen"].toString()) : null,
      masterentityPricebookmodeharga: json["masterentity_pricebookmodeharga"]?.toString(),
      masterentityPricebookisdefault: json["masterentity_pricebookisdefault"]?.toString(),
      masterentityPricebookstart: json["masterentity_pricebookstart"] != null ? int.tryParse(json["masterentity_pricebookstart"].toString()) : null,
      masterentityPricebookend: json["masterentity_pricebookend"] != null ? int.tryParse(json["masterentity_pricebookend"].toString()) : null,
      masterentityPricebookwaktustart: json["masterentity_pricebookwaktustart"]?.toString(),
      masterentityPricebookwaktuend: json["masterentity_pricebookwaktuend"]?.toString(),
      masterentityPricebookispersen: json["masterentity_pricebookispersen"]?.toString(),
      masterentityPromotype: json["masterentity_promotype"]?.toString(),
      masterentityIspromomultiply: json["masterentity_ispromomultiply"]?.toString(),
      masterentityIspromotunggal: json["masterentity_ispromotunggal"]?.toString(),
      masterentityIspromovoucher: json["masterentity_ispromovoucher"]?.toString(),
      masterentityPromosyarat: json["masterentity_promosyarat"] != null ? double.tryParse(json["masterentity_promosyarat"].toString()) : null,
      masterentityPromomendapatkan: json["masterentity_promomendapatkan"] != null ? double.tryParse(json["masterentity_promomendapatkan"].toString()) : null,
      masterentityPromoquota: json["masterentity_promoquota"] != null ? int.tryParse(json["masterentity_promoquota"].toString()) : null,
      masterentityPromoisgiftvoucher: json["masterentity_promoisgiftvoucher"]?.toString(),
      masterentityPromorelasiandor: json["masterentity_promorelasiandor"]?.toString(),
      masterentityPromobranddiscline: json["masterentity_promobranddiscline"] != null ? int.tryParse(json["masterentity_promobranddiscline"].toString()) : null,
      masterentityPromobrandminimitem: json["masterentity_promobrandminimitem"] != null ? int.tryParse(json["masterentity_promobrandminimitem"].toString()) : null,
      masterentityCountsum: json["masterentity_countsum"] != null ? int.tryParse(json["masterentity_countsum"].toString()) : null,
      masterentityLimitqtynotaunpaid: json["masterentity_limitqtynotaunpaid"] != null ? int.tryParse(json["masterentity_limitqtynotaunpaid"].toString()) : null,
      masterentityLimitmaxhari: json["masterentity_limitmaxhari"] != null ? int.tryParse(json["masterentity_limitmaxhari"].toString()) : null,
      masterentityStartstring: json["masterentity_startstring"]?.toString(),
      masterentityEndstring: json["masterentity_endstring"]?.toString(),
      masterentityIptimbangan: json["masterentity_iptimbangan"]?.toString(),
      masterentityPorttimbangan: json["masterentity_porttimbangan"] != null ? int.tryParse(json["masterentity_porttimbangan"].toString()) : null,
      masterentityBarcode: json["masterentity_barcode"]?.toString(),
      masterentityStockmin: json["masterentity_stockmin"] != null ? double.tryParse(json["masterentity_stockmin"].toString()) : null,
      masterentityStockmax: json["masterentity_stockmax"] != null ? double.tryParse(json["masterentity_stockmax"].toString()) : null,
      masterentityQtysellmin: json["masterentity_qtysellmin"] != null ? double.tryParse(json["masterentity_qtysellmin"].toString()) : null,
      masterentityQtysellmax: json["masterentity_qtysellmax"] != null ? double.tryParse(json["masterentity_qtysellmax"].toString()) : null,
      masterentityFixtglperolehan: json["masterentity_fixtglperolehan"] != null ? int.tryParse(json["masterentity_fixtglperolehan"].toString()) : null,
      masterentityFixtglmulaisusut: json["masterentity_fixtglmulaisusut"] != null ? int.tryParse(json["masterentity_fixtglmulaisusut"].toString()) : null,
      masterentityFixtglterjual: json["masterentity_fixtglterjual"] != null ? int.tryParse(json["masterentity_fixtglterjual"].toString()) : null,
      masterentityFixtaxrate: json["masterentity_fixtaxrate"] != null ? double.tryParse(json["masterentity_fixtaxrate"].toString()) : null,
      masterentityFixtaxratejual: json["masterentity_fixtaxratejual"] != null ? double.tryParse(json["masterentity_fixtaxratejual"].toString()) : null,
      masterentityPersentasesusut: json["masterentity_persentasesusut"] != null ? double.tryParse(json["masterentity_persentasesusut"].toString()) : null,
      masterentityFixdurasipenyusutan: json["masterentity_fixdurasipenyusutan"] != null ? int.tryParse(json["masterentity_fixdurasipenyusutan"].toString()) : null,
      masterentityFixratepenyusutan: json["masterentity_fixratepenyusutan"] != null ? double.tryParse(json["masterentity_fixratepenyusutan"].toString()) : null,
      masterentityFixsusutvalue: json["masterentity_fixsusutvalue"] != null ? double.tryParse(json["masterentity_fixsusutvalue"].toString()) : null,
      masterentityFixtaxvalue: json["masterentity_fixtaxvalue"] != null ? double.tryParse(json["masterentity_fixtaxvalue"].toString()) : null,
      masterentityFixtaxvaluejual: json["masterentity_fixtaxvaluejual"] != null ? double.tryParse(json["masterentity_fixtaxvaluejual"].toString()) : null,
      masterentityFixsalvagevalue: json["masterentity_fixsalvagevalue"] != null ? double.tryParse(json["masterentity_fixsalvagevalue"].toString()) : null,
      masterentityIsbatchserial: json["masterentity_isbatchserial"]?.toString(),
      masterentityIstara: json["masterentity_istara"]?.toString(),
      masterentityIssupplier: json["masterentity_issupplier"]?.toString(),
      masterentityIscustomer: json["masterentity_iscustomer"]?.toString(),
      masterentityIsemployee: json["masterentity_isemployee"]?.toString(),
      masterentityIssales: json["masterentity_issales"]?.toString(),
      mastereneityIsgrader: json["mastereneity_isgrader"]?.toString(),
      masterentityIspecahan: json["masterentity_ispecahan"]?.toString(),
      masterentityIsincludeppn: json["masterentity_isincludeppn"]?.toString(),
      masterentityIssuperuser: json["masterentity_issuperuser"]?.toString(),
      masterentityIsgudangsum: json["masterentity_isgudangsum"]?.toString(),
      masterentityIsstock: json["masterentity_isstock"]?.toString(),
      masterentityIssold: json["masterentity_issold"]?.toString(),
      masterentityIspurch: json["masterentity_ispurch"]?.toString(),
      masterentityIsinassembly: json["masterentity_isinassembly"]?.toString(),
      masterentityIsoutassembly: json["masterentity_isoutassembly"]?.toString(),
      masterentityIssaldoawal: json["masterentity_issaldoawal"]?.toString(),
      masterentityIsadjustment: json["masterentity_isadjustment"]?.toString(),
      masterentityPajaknomornpwp: json["masterentity_pajaknomornpwp"]?.toString(),
      masterentityPajaknamanpwp: json["masterentity_pajaknamanpwp"]?.toString(),
      masterentityPajakalamatnpwp: json["masterentity_pajakalamatnpwp"]?.toString(),
      masterentityPajakblok: json["masterentity_pajakblok"]?.toString(),
      masterentityPajaknomor: json["masterentity_pajaknomor"]?.toString(),
      masterentityPajakrt: json["masterentity_pajakrt"]?.toString(),
      masterentityPajakrw: json["masterentity_pajakrw"]?.toString(),
      masterentityPajakkecamatan: json["masterentity_pajakkecamatan"]?.toString(),
      masterentityPajakkelurahan: json["masterentity_pajakkelurahan"]?.toString(),
      masterentityPajakkabupaten: json["masterentity_pajakkabupaten"]?.toString(),
      masterentityPajakprovinsi: json["masterentity_pajakprovinsi"]?.toString(),
      masterentityPajakkodepos: json["masterentity_pajakkodepos"]?.toString(),
      masterentityBuyertin: json["masterentity_buyertin"]?.toString(),
      masterentityBuyerdocument: json["masterentity_buyerdocument"]?.toString(),
      masterentityBuyerdocumentnumber: json["masterentity_buyerdocumentnumber"]?.toString(),
      masterentityBuyeridtku: json["masterentity_buyeridtku"]?.toString(),
      masterentityCatatan: json["masterentity_catatan"]?.toString(),
      masterentityPajakopsifaktur: json["masterentity_pajakopsifaktur"]?.toString(),
      masterentityModelabel: json["masterentity_modelabel"] != null ? int.tryParse(json["masterentity_modelabel"].toString()) : null,
      masterentityStatus: json["masterentity_status"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "masterentity_id": masterentityId,
      "masterentityparent_id": masterentityparentId,
      "masterpartner_id": masterpartnerId,
      "masterpartnerjual_id": masterpartnerjualId,
      "masterstore_id": masterstoreId,
      "masterpartnercategory_id": masterpartnercategoryId,
      "masteraccountsubclass_id": masteraccountsubclassId,
      "masteritemtype_id": masteritemtypeId,
      "masteritemcategory_id": masteritemcategoryId,
      "masterassetcategory_id": masterassetcategoryId,
      "mastertax_id": mastertaxId,
      "mastertaxjual_id": mastertaxjualId,
      "masteruom_id": masteruomId,
      "masterbrand_id": masterbrandId,
      "masterkurs_id": masterkursId,
      "mastertermin_id": masterterminId,
      "masterterminjual_id": masterterminjualId,
      "masteraccount_id": masteraccountId,
      "masteraccountjual_id": masteraccountjualId,
      "masteraccount_itemcategorypersediaan_id": masteraccountItemcategorypersediaanId,
      "masteraccount_itemcategoryhpp_id": masteraccountItemcategoryhppId,
      "masteraccount_itemcategoryjual_id": masteraccountItemcategoryjualId,
      "masteraccount_itemcategoryjualretur_id": masteraccountItemcategoryjualreturId,
      "masteraccount_itemcategoryjualdisc_id": masteraccountItemcategoryjualdiscId,
      "masteraccount_itemcategoryppnmasuk_id": masteraccountItemcategoryppnmasukId,
      "masteraccount_itemcategoryppnkeluar_id": masteraccountItemcategoryppnkeluarId,
      "masteraccount_fixasset_id": masteraccountFixassetId,
      "masteraccount_fixassetexpense_id": masteraccountFixassetexpenseId,
      "masteraccount_fixassetakumulasi_id": masteraccountFixassetakumulasiId,
      "masteraccount_fixassetkeuntungan_id": masteraccountFixassetkeuntunganId,
      "masteraccount_fixassetkerugian_id": masteraccountFixassetkerugianId,
      "masteraccount_fixassetperawatan_id": masteraccountFixassetperawatanId,
      "masteraccount_fixassetppnmasukan_id": masteraccountFixassetppnmasukanId,
      "masteraccount_fixassetppnkeluaran_id": masteraccountFixassetppnkeluaranId,
      "masterusercategory_id": masterusercategoryId,
      "masterareaproduksi_id": masterareaproduksiId,
      "masterprinter_id": masterprinterId,
      "masteruser_id": masteruserId,
      "masterdepartment_id": masterdepartmentId,
      "masterjabatan_id": masterjabatanId,
      "masterbussiness_id": masterbussinessId,
      "masterentity_type": masterentityType,
      "masterentity_description": masterentityDescription,
      "masterentity_alias": masterentityAlias,
      "masterentity_aliasinternal": masterentityAliasinternal,
      "masterentity_aliasproduksi": masterentityAliasproduksi,
      "masterentity_aliasexternal": masterentityAliasexternal,
      "masterentity_keterangan": masterentityKeterangan,
      "masterentity_namaprinter": masterentityNamaprinter,
      "masterentity_fixmodepenyusutan": masterentityFixmodepenyusutan,
      "masterentity_nilai": masterentityNilai,
      "masterentity_nilai02": masterentityNilai02,
      "masterentity_cardchargespersen": masterentityCardchargespersen,
      "masterentity_pricebookmodeharga": masterentityPricebookmodeharga,
      "masterentity_pricebookisdefault": masterentityPricebookisdefault,
      "masterentity_pricebookstart": masterentityPricebookstart,
      "masterentity_pricebookend": masterentityPricebookend,
      "masterentity_pricebookwaktustart": masterentityPricebookwaktustart,
      "masterentity_pricebookwaktuend": masterentityPricebookwaktuend,
      "masterentity_pricebookispersen": masterentityPricebookispersen,
      "masterentity_promotype": masterentityPromotype,
      "masterentity_ispromomultiply": masterentityIspromomultiply,
      "masterentity_ispromotunggal": masterentityIspromotunggal,
      "masterentity_ispromovoucher": masterentityIspromovoucher,
      "masterentity_promosyarat": masterentityPromosyarat,
      "masterentity_promomendapatkan": masterentityPromomendapatkan,
      "masterentity_promoquota": masterentityPromoquota,
      "masterentity_promoisgiftvoucher": masterentityPromoisgiftvoucher,
      "masterentity_promorelasiandor": masterentityPromorelasiandor,
      "masterentity_promobranddiscline": masterentityPromobranddiscline,
      "masterentity_promobrandminimitem": masterentityPromobrandminimitem,
      "masterentity_countsum": masterentityCountsum,
      "masterentity_limitqtynotaunpaid": masterentityLimitqtynotaunpaid,
      "masterentity_limitmaxhari": masterentityLimitmaxhari,
      "masterentity_startstring": masterentityStartstring,
      "masterentity_endstring": masterentityEndstring,
      "masterentity_iptimbangan": masterentityIptimbangan,
      "masterentity_porttimbangan": masterentityPorttimbangan,
      "masterentity_barcode": masterentityBarcode,
      "masterentity_stockmin": masterentityStockmin,
      "masterentity_stockmax": masterentityStockmax,
      "masterentity_qtysellmin": masterentityQtysellmin,
      "masterentity_qtysellmax": masterentityQtysellmax,
      "masterentity_fixtglperolehan": masterentityFixtglperolehan,
      "masterentity_fixtglmulaisusut": masterentityFixtglmulaisusut,
      "masterentity_fixtglterjual": masterentityFixtglterjual,
      "masterentity_fixtaxrate": masterentityFixtaxrate,
      "masterentity_fixtaxratejual": masterentityFixtaxratejual,
      "masterentity_persentasesusut": masterentityPersentasesusut,
      "masterentity_fixdurasipenyusutan": masterentityFixdurasipenyusutan,
      "masterentity_fixratepenyusutan": masterentityFixratepenyusutan,
      "masterentity_fixsusutvalue": masterentityFixsusutvalue,
      "masterentity_fixtaxvalue": masterentityFixtaxvalue,
      "masterentity_fixtaxvaluejual": masterentityFixtaxvaluejual,
      "masterentity_fixsalvagevalue": masterentityFixsalvagevalue,
      "masterentity_isbatchserial": masterentityIsbatchserial,
      "masterentity_istara": masterentityIstara,
      "masterentity_issupplier": masterentityIssupplier,
      "masterentity_iscustomer": masterentityIscustomer,
      "masterentity_isemployee": masterentityIsemployee,
      "masterentity_issales": masterentityIssales,
      "mastereneity_isgrader": mastereneityIsgrader,
      "masterentity_ispecahan": masterentityIspecahan,
      "masterentity_isincludeppn": masterentityIsincludeppn,
      "masterentity_issuperuser": masterentityIssuperuser,
      "masterentity_isgudangsum": masterentityIsgudangsum,
      "masterentity_isstock": masterentityIsstock,
      "masterentity_issold": masterentityIssold,
      "masterentity_ispurch": masterentityIspurch,
      "masterentity_isinassembly": masterentityIsinassembly,
      "masterentity_isoutassembly": masterentityIsoutassembly,
      "masterentity_issaldoawal": masterentityIssaldoawal,
      "masterentity_isadjustment": masterentityIsadjustment,
      "masterentity_pajaknomornpwp": masterentityPajaknomornpwp,
      "masterentity_pajaknamanpwp": masterentityPajaknamanpwp,
      "masterentity_pajakalamatnpwp": masterentityPajakalamatnpwp,
      "masterentity_pajakblok": masterentityPajakblok,
      "masterentity_pajaknomor": masterentityPajaknomor,
      "masterentity_pajakrt": masterentityPajakrt,
      "masterentity_pajakrw": masterentityPajakrw,
      "masterentity_pajakkecamatan": masterentityPajakkecamatan,
      "masterentity_pajakkelurahan": masterentityPajakkelurahan,
      "masterentity_pajakkabupaten": masterentityPajakkabupaten,
      "masterentity_pajakprovinsi": masterentityPajakprovinsi,
      "masterentity_pajakkodepos": masterentityPajakkodepos,
      "masterentity_buyertin": masterentityBuyertin,
      "masterentity_buyerdocument": masterentityBuyerdocument,
      "masterentity_buyerdocumentnumber": masterentityBuyerdocumentnumber,
      "masterentity_buyeridtku": masterentityBuyeridtku,
      "masterentity_catatan": masterentityCatatan,
      "masterentity_pajakopsifaktur": masterentityPajakopsifaktur,
      "masterentity_modelabel": masterentityModelabel,
      "masterentity_status": masterentityStatus,
    };
  }
}

class Masterbussiness {
  final String? masterbussinessId;
  final String? masterbussinessparentId;
  final String? masterbussinessDescription;
  final String? masterbussinessStatus;

  Masterbussiness({
    this.masterbussinessId,
    this.masterbussinessparentId,
    this.masterbussinessDescription,
    this.masterbussinessStatus,
  });

  factory Masterbussiness.fromJson(Map<String, dynamic> json) {
    return Masterbussiness(
      masterbussinessId: json["masterbussiness_id"]?.toString(),
      masterbussinessparentId: json["masterbussinessparent_id"]?.toString(),
      masterbussinessDescription: json["masterbussiness_description"]?.toString(),
      masterbussinessStatus: json["masterbussiness_status"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "masterbussiness_id": masterbussinessId,
      "masterbussinessparent_id": masterbussinessparentId,
      "masterbussiness_description": masterbussinessDescription,
      "masterbussiness_status": masterbussinessStatus,
    };
  }
}

