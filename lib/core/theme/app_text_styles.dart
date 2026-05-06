import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle displayXL({Color? color}) => GoogleFonts.inter(
    fontSize: 56, fontWeight: FontWeight.w700,
    letterSpacing: -1.4, height: 1.04, color: color,
  );

  static TextStyle displayLG({Color? color}) => GoogleFonts.inter(
    fontSize: 40, fontWeight: FontWeight.w700,
    letterSpacing: -0.8, height: 1.08, color: color,
  );

  static TextStyle h1({Color? color}) => GoogleFonts.inter(
    fontSize: 28, fontWeight: FontWeight.w600,
    letterSpacing: -0.5, height: 1.14, color: color,
  );

  static TextStyle h2({Color? color}) => GoogleFonts.inter(
    fontSize: 22, fontWeight: FontWeight.w600,
    letterSpacing: -0.31, height: 1.18, color: color,
  );

  static TextStyle h3({Color? color}) => GoogleFonts.inter(
    fontSize: 18, fontWeight: FontWeight.w500,
    letterSpacing: -0.14, height: 1.22, color: color,
  );

  static TextStyle h4({Color? color}) => GoogleFonts.inter(
    fontSize: 16, fontWeight: FontWeight.w600,
    letterSpacing: -0.08, height: 1.25, color: color,
  );

  static TextStyle body({Color? color}) => GoogleFonts.inter(
    fontSize: 16, fontWeight: FontWeight.w400,
    letterSpacing: 0, height: 1.5, color: color,
  );

  static TextStyle bodySm({Color? color}) => GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w400,
    letterSpacing: 0, height: 1.5, color: color,
  );

  static TextStyle bodySmMedium({Color? color}) => GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w500,
    letterSpacing: 0, height: 1.5, color: color,
  );

  static TextStyle bodySmSemibold({Color? color}) => GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w600,
    letterSpacing: 0, height: 1.5, color: color,
  );

  static TextStyle meta({Color? color}) => GoogleFonts.inter(
    fontSize: 13, fontWeight: FontWeight.w500,
    letterSpacing: 0.026, height: 1.4, color: color,
  );

  static TextStyle metaSemibold({Color? color}) => GoogleFonts.inter(
    fontSize: 13, fontWeight: FontWeight.w600,
    letterSpacing: 0.026, height: 1.4, color: color,
  );

  static TextStyle micro({Color? color}) => GoogleFonts.inter(
    fontSize: 11, fontWeight: FontWeight.w600,
    letterSpacing: 0.44, height: 1.2, color: color,
  );

  static TextStyle numericLarge({Color? color}) => GoogleFonts.inter(
    fontSize: 52, fontWeight: FontWeight.w800,
    letterSpacing: -1.0, height: 1.0, color: color,
  );

  static TextStyle numericMed({Color? color}) => GoogleFonts.inter(
    fontSize: 32, fontWeight: FontWeight.w700,
    letterSpacing: -0.5, height: 1.1, color: color,
  );
}
