# NAD83/WGS84 Global Variables
# Equatorial Radius, meters (a)	= 6,378,137
# Polar Radius, meters (b) = 6,356,752.3142
# Flattening (a-b)/a = 1/298.257223563

CREATE OR REPLACE FUNCTION latlong_to_utm_nad83(lat double precision, long double precision)
RETURNS varchar AS utm



function latlong_to_utm(lat , Lon in number, a in number, InverseFlattening in number)
  return varchar2
  is result varchar2(320);
  ZoneWidth CONSTANT number := 6;
  CentralScaleFactor CONSTANT number := 0.9996;
  Zone1CentralMeridian CONSTANT number := -177;
  Zone0WestMeridian number;
  Zone0CentralMeridian number;
  FalseEasting CONSTANT number := 500000;

  Pi number;
  SemiMajorAxis number;
  Flattening number; Eccent2 number; Eccent4 number; Eccent6 number;
  A0 number; A2 number; A4 number; A6 number;
  LatRad  number;
  LonRad  number;
  Sin1Lat  number; Sin2Lat  number; Sin4Lat  number; Sin6Lat  number;
  Rho  number;
  Nu  number;
  Psi  number; Psi2  number; Psi3  number; Psi4   number;
  CosLat  number; CosLat2  number; CosLat3  number; CosLat4  number; CosLat5   number;
  CosLat6  number; CosLat7    number;
  TanLat  number; TanLat2  number; TanLat4  number; TanLat6    number;
  DifLon  number; DifLon2  number; DifLon3  number; DifLon4  number; DifLon5   number;
  DifLon6 number; DifLon7  number; DifLon8   number;
  DistOverMeridian    number;
  Zone  number;
  CentralMeridian  Integer;
  East1  number; East2  number; East3  number; East4  number;
  North1  number; North2  number; North3  number; North4  number;
  X  number;
  Y  number;
  Hemi  varchar2(1);
  FalseNorthing  number;

begin
Zone0WestMeridian := Zone1CentralMeridian - (1.5 * ZoneWidth);
Zone0CentralMeridian := Zone0WestMeridian + ZoneWidth / 2;
Pi := 3.141592653589793238462643383279502884197169399375105820974944592307816406;


SemiMajorAxis := 1000 * a  ;

Flattening := 1.0 / InverseFlattening   ;
Eccent2 := 2.0 * Flattening - (Flattening * Flattening);
Eccent4 := Eccent2 * Eccent2   ;
Eccent6 := Eccent2 * Eccent4 ;
A0 := 1 - (Eccent2 / 4.0) - ((3 * Eccent4) / 64.0) - ((5.0 * Eccent6) / 256.0);
A2 := (3.0 / 8.0) * (Eccent2 + (Eccent4 / 4.0) + ((15.0 * Eccent6) / 128.0)) ;
A4 := (15 / 256) * (Eccent4 + ((3.0 * Eccent6) / 4.0));
A6 := (35.0 * Eccent6) / 3072.0 ;
  --  ' Parameters to radians
    LatRad := lat / 180 * Pi;
    LonRad := Lon / 180 * Pi ;


  --  'Sin of latitude and its multiples
    Sin1Lat := sIn(LatRad) ;
    Sin2Lat := sIn(2 * LatRad) ;
    Sin4Lat := sIn(4 * LatRad);
    Sin6Lat := sIn(6 * LatRad);

  --  'Meridian Distance
    DistOverMeridian := SemiMajorAxis * 
                        (A0 * LatRad - A2 * Sin2Lat + A4 * Sin4Lat - A6 * Sin6Lat);


  --  'Radii of Curvature
    Rho := SemiMajorAxis * (1 - Eccent2) /Power( (1 - 
           (Eccent2 * Sin1Lat * Sin1Lat)) , 1.5);
    Nu := SemiMajorAxis /Power( (1 - (Eccent2 * Sin1Lat * Sin1Lat)) , 0.5);
    Psi := Nu / Rho  ;
    Psi2 := Psi * Psi ;
    Psi3 := Psi * Psi2;
    Psi4 := Psi * Psi3  ;

  --  'Powers of cos latitude
    CosLat := Cos(LatRad);
    CosLat2 := CosLat * CosLat  ;
    CosLat3 := CosLat * CosLat2 ;
    CosLat4 := CosLat * CosLat3 ;
    CosLat5 := CosLat * CosLat4 ;
    CosLat6 := CosLat * CosLat5 ;
    CosLat7 := CosLat * CosLat6 ;


--    'Powers of tan latitude
    TanLat := Tan(LatRad) ;
    TanLat2 := TanLat * TanLat ;
    TanLat4 := TanLat2 * TanLat2  ;
    TanLat6 := TanLat2 * TanLat4  ;

 --   'Zone
 --   'Zone := Int((Lon - Zone0WestMeridian) / ZoneWidth)
    Zone := UTMZone(lat, Lon)   ;



    CentralMeridian := Trunc((Zone * ZoneWidth) + Zone0CentralMeridian ) ;
    DifLon := (Lon - CentralMeridian) / 180 * Pi    ;
    DifLon2 := DifLon * DifLon  ;
    DifLon3 := DifLon * DifLon2 ;
    DifLon4 := DifLon * DifLon3 ;
    DifLon5 := DifLon * DifLon4 ;
    DifLon6 := DifLon * DifLon5 ;
    DifLon7 := DifLon * DifLon6 ;
    DifLon8 := DifLon * DifLon7 ;

    East1 := DifLon * CosLat  ;
    East2 := DifLon3 * CosLat3 * (Psi - TanLat2) / 6.0;
    East3 := DifLon5 * CosLat5 * (4.0 * Psi3 * (1.0 - 6.0 * TanLat2) + Psi2 * 
    (1.0 + 8.0 * TanLat2) -Psi * (2.0 * TanLat2) + TanLat4) / 120.0;
    East4 := DifLon7 * CosLat7 * (61.0 - 479.0 * TanLat2 + 179.0 * TanLat4 - TanLat6) 
    / 5040.0  ;
    X := CentralScaleFactor * Nu * (East1 + East2 + East3 + East4) + FalseEasting  ;

    If (lat >= 0) Then
      Hemi := 'N';
      FalseNorthing := 0;
    Else
      Hemi := 'S';
      FalseNorthing := 10000000;
    end if;

    North1 := Sin1Lat * DifLon2 * CosLat / 2.0 ;
    North2 := Sin1Lat * DifLon4 * CosLat3 * (4.0 * Psi2 + Psi - TanLat2) / 24.0 ;
    North3 := Sin1Lat * DifLon6 * CosLat5 * (8.0 * Psi4 * (11.0 - 24.0 * TanLat2)
              - 28.0 * Psi3 * (1.0 - 6.0 * TanLat2) +
     Psi2 * (1.0 - 32.0 * TanLat2) - Psi * (2.0 * TanLat2) + TanLat4) / 720;
    North4 := Sin1Lat * DifLon8 * CosLat7 * (1385 - 3111 * TanLat2 + 543 * 
              TanLat4 - TanLat6) / 40320.0 ;
    Y := CentralScaleFactor * (DistOverMeridian + Nu *
         (North1 + North2 + North3 + North4)) + FalseNorthing;

  Result := Zone || Hemi || ' ' || 
            to_char(round(X, 3),'0000000.000') || 
            to_char(round(Y, 3),'0000000.000');
  return result;
End UTM;