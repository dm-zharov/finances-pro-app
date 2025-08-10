//
//  CurrencyRates+CoreDataProperties.swift
//  Finances
//
//  Created by Dmitriy Zharov on 10.11.2023.
//
//

import Foundation
import CoreData


extension CurrencyRates {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CurrencyRates> {
        return NSFetchRequest<CurrencyRates>(entityName: "CurrencyRates")
    }

    @NSManaged public var aed: Double
    @NSManaged public var afn: Double
    @NSManaged public var all: Double
    @NSManaged public var amd: Double
    @NSManaged public var ang: Double
    @NSManaged public var aoa: Double
    @NSManaged public var ars: Double
    @NSManaged public var aud: Double
    @NSManaged public var awg: Double
    @NSManaged public var azn: Double
    @NSManaged public var bam: Double
    @NSManaged public var bbd: Double
    @NSManaged public var bdt: Double
    @NSManaged public var bgn: Double
    @NSManaged public var bhd: Double
    @NSManaged public var bif: Double
    @NSManaged public var bmd: Double
    @NSManaged public var bnd: Double
    @NSManaged public var bob: Double
    @NSManaged public var brl: Double
    @NSManaged public var bsd: Double
    @NSManaged public var btc: Double
    @NSManaged public var btn: Double
    @NSManaged public var bwp: Double
    @NSManaged public var byn: Double
    @NSManaged public var bzd: Double
    @NSManaged public var cad: Double
    @NSManaged public var cdf: Double
    @NSManaged public var chf: Double
    @NSManaged public var clf: Double
    @NSManaged public var clp: Double
    @NSManaged public var cnh: Double
    @NSManaged public var cny: Double
    @NSManaged public var cop: Double
    @NSManaged public var crc: Double
    @NSManaged public var cuc: Double
    @NSManaged public var cup: Double
    @NSManaged public var cve: Double
    @NSManaged public var czk: Double
    @NSManaged public var djf: Double
    @NSManaged public var dkk: Double
    @NSManaged public var dop: Double
    @NSManaged public var dzd: Double
    @NSManaged public var egp: Double
    @NSManaged public var ern: Double
    @NSManaged public var etb: Double
    @NSManaged public var eur: Double
    @NSManaged public var fjd: Double
    @NSManaged public var fkp: Double
    @NSManaged public var gbp: Double
    @NSManaged public var gel: Double
    @NSManaged public var ggp: Double
    @NSManaged public var ghs: Double
    @NSManaged public var gip: Double
    @NSManaged public var gmd: Double
    @NSManaged public var gnf: Double
    @NSManaged public var gtq: Double
    @NSManaged public var gyd: Double
    @NSManaged public var hkd: Double
    @NSManaged public var hnl: Double
    @NSManaged public var hrk: Double
    @NSManaged public var htg: Double
    @NSManaged public var huf: Double
    @NSManaged public var idr: Double
    @NSManaged public var ils: Double
    @NSManaged public var imp: Double
    @NSManaged public var inr: Double
    @NSManaged public var iqd: Double
    @NSManaged public var irr: Double
    @NSManaged public var isk: Double
    @NSManaged public var jep: Double
    @NSManaged public var jmd: Double
    @NSManaged public var jod: Double
    @NSManaged public var jpy: Double
    @NSManaged public var kes: Double
    @NSManaged public var kgs: Double
    @NSManaged public var khr: Double
    @NSManaged public var kmf: Double
    @NSManaged public var kpw: Double
    @NSManaged public var krw: Double
    @NSManaged public var kwd: Double
    @NSManaged public var kyd: Double
    @NSManaged public var kzt: Double
    @NSManaged public var lak: Double
    @NSManaged public var lbp: Double
    @NSManaged public var lkr: Double
    @NSManaged public var lrd: Double
    @NSManaged public var lsl: Double
    @NSManaged public var lyd: Double
    @NSManaged public var mad: Double
    @NSManaged public var mdl: Double
    @NSManaged public var mga: Double
    @NSManaged public var mkd: Double
    @NSManaged public var mmk: Double
    @NSManaged public var mnt: Double
    @NSManaged public var mop: Double
    @NSManaged public var mru: Double
    @NSManaged public var mur: Double
    @NSManaged public var mvr: Double
    @NSManaged public var mwk: Double
    @NSManaged public var mxn: Double
    @NSManaged public var myr: Double
    @NSManaged public var mzn: Double
    @NSManaged public var nad: Double
    @NSManaged public var ngn: Double
    @NSManaged public var nio: Double
    @NSManaged public var nok: Double
    @NSManaged public var npr: Double
    @NSManaged public var nzd: Double
    @NSManaged public var omr: Double
    @NSManaged public var pab: Double
    @NSManaged public var pen: Double
    @NSManaged public var pgk: Double
    @NSManaged public var php: Double
    @NSManaged public var pkr: Double
    @NSManaged public var pln: Double
    @NSManaged public var pyg: Double
    @NSManaged public var qar: Double
    @NSManaged public var ron: Double
    @NSManaged public var rsd: Double
    @NSManaged public var rub: Double
    @NSManaged public var rwf: Double
    @NSManaged public var sar: Double
    @NSManaged public var sbd: Double
    @NSManaged public var scr: Double
    @NSManaged public var sdg: Double
    @NSManaged public var sek: Double
    @NSManaged public var sgd: Double
    @NSManaged public var shp: Double
    @NSManaged public var sll: Double
    @NSManaged public var sos: Double
    @NSManaged public var srd: Double
    @NSManaged public var ssp: Double
    @NSManaged public var std: Double
    @NSManaged public var stn: Double
    @NSManaged public var svc: Double
    @NSManaged public var syp: Double
    @NSManaged public var szl: Double
    @NSManaged public var thb: Double
    @NSManaged public var tjs: Double
    @NSManaged public var tmt: Double
    @NSManaged public var tnd: Double
    @NSManaged public var top: Double
    @NSManaged public var `try`: Double
    @NSManaged public var ttd: Double
    @NSManaged public var twd: Double
    @NSManaged public var tzs: Double
    @NSManaged public var uah: Double
    @NSManaged public var ugx: Double
    @NSManaged public var usd: Double
    @NSManaged public var uyu: Double
    @NSManaged public var uzs: Double
    @NSManaged public var vef: Double
    @NSManaged public var ves: Double
    @NSManaged public var vnd: Double
    @NSManaged public var vuv: Double
    @NSManaged public var wst: Double
    @NSManaged public var xaf: Double
    @NSManaged public var xag: Double
    @NSManaged public var xau: Double
    @NSManaged public var xcd: Double
    @NSManaged public var xdr: Double
    @NSManaged public var xof: Double
    @NSManaged public var xpd: Double
    @NSManaged public var xpf: Double
    @NSManaged public var xpt: Double
    @NSManaged public var yer: Double
    @NSManaged public var zar: Double
    @NSManaged public var zmw: Double
    @NSManaged public var zwl: Double

}

extension CurrencyRates : Identifiable {

}
