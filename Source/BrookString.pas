(*    _____   _____    _____   _____   _   __
 *   |  _  \ |  _  \  /  _  \ /  _  \ | | / /
 *   | |_) | | |_) |  | | | | | | | | | |/ /
 *   |  _ <  |  _ <   | | | | | | | | |   (
 *   | |_) | | | \ \  | |_| | | |_| | | |\ \
 *   |_____/ |_|  \_\ \_____/ \_____/ |_| \_\
 *
 *   –– a small library which helps you write quickly REST APIs.
 *
 * Copyright (c) 2012-2018 Silvio Clecio <silvioprog@gmail.com>
 *
 * This file is part of Brook library.
 *
 * Brook library is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Brook library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with Brook library.  If not, see <http://www.gnu.org/licenses/>.
 *)

{ String type used to represent a HTML body, POST payload and more. }

unit BrookString;

{$I Brook.inc}

interface

uses
  RTLConsts,
  SysUtils,
  Classes,
  libbrook,
  Marshalling,
  BrookHandledClasses;

{ TODO: TBrookString.Assign() }
{ TODO: details about the method parameters. }

type
  { String class and its related methods. }
  TBrookString = class(TBrookHandledPersistent)
  private
    Fstr: Pbk_str;
    FOwnsHandle: Boolean;
    function GetContent: TBytes;
    function GetLength: NativeUInt;
  protected
    function GetHandle: Pointer; override;
    function GetOwnsHandle: Boolean; override;
    procedure SetOwnsHandle(AValue: Boolean); override;
    class procedure CheckEncoding(AEncoding: TEncoding); static; inline;
  public
    { Creates an instance of TBrookString. }
    constructor Create(AHandle: Pointer); virtual;
    { Frees an instance of TBrookString. }
    destructor Destroy; override;
    { Writes a string buffer to the string handle. All strings previously
      written are kept. }
    function Write(const AValue: TBytes;
      ALength: NativeUInt): NativeUInt; virtual;
    { Reads a string buffer from the string handle. }
    function Read(AValue: TBytes; ALength: NativeUInt): NativeUInt; virtual;
    { Writes a formatted string to the string handle. All strings previously
      written are kept. }
    procedure Format(const AFmt: string; const AArgs: array of const;
      AFormatSettings: TFormatSettings; AEncoding: TEncoding); overload; virtual;
    { Writes a formatted string to the string handle. All strings previously
      written are kept. }
    procedure Format(const AFmt: string; const AArgs: array of const;
      AFormatSettings: TFormatSettings); overload; virtual;
    { Writes a formatted string to the string handle. All strings previously
      written are kept. }
    procedure Format(const AFmt: string;
      const AArgs: array of const); overload; virtual;
    { Gets the content buffer as text. }
    function AsText(AEncoding: TEncoding): string; overload; virtual;
    { Gets the content buffer as text. }
    function AsText: string; overload; virtual;
    { Cleans all the content present in the string handle. }
    procedure Clear; virtual;
    { Gets the content buffer from the string handle. }
    property Content: TBytes read GetContent;
    { Gets the content length from the string handle. }
    property Length: NativeUInt read GetLength;
  end;

implementation

constructor TBrookString.Create(AHandle: Pointer);
begin
  inherited Create;
  FOwnsHandle := not Assigned(AHandle);
  if FOwnsHandle then
    Fstr := bk_str_new;
end;

destructor TBrookString.Destroy;
begin
  if FOwnsHandle then
    bk_str_free(Fstr);
  inherited Destroy;
end;

function TBrookString.GetHandle: Pointer;
begin
  Result := Fstr;
end;

function TBrookString.GetOwnsHandle: Boolean;
begin
  Result := FOwnsHandle;
end;

procedure TBrookString.SetOwnsHandle(AValue: Boolean);
begin
  FOwnsHandle := AValue;
end;

class procedure TBrookString.CheckEncoding(AEncoding: TEncoding);
begin
  if not Assigned(AEncoding) then
    raise EArgumentNilException.CreateResFmt(@SParamIsNil, ['AEncoding']);
end;

function TBrookString.Write(const AValue: TBytes;
  ALength: NativeUInt): NativeUInt;
begin
  CheckHandle;
  Result := ALength;
  CheckOSError(bk_str_write(Fstr, @AValue[0], Result));
end;

function TBrookString.Read(AValue: TBytes; ALength: NativeUInt): NativeUInt;
begin
  CheckHandle;
  Result := ALength;
  CheckOSError(bk_str_read(Fstr, @AValue[0], @ALength));
end;

{$IFDEF FPC}{$PUSH}{$WARN 4104 OFF}{$ENDIF}
procedure TBrookString.Format(const AFmt: string; const AArgs: array of const;
  AFormatSettings: TFormatSettings; AEncoding: TEncoding);
var
  VBytes: TBytes;
begin
  CheckHandle;
  CheckEncoding(AEncoding);
  VBytes := AEncoding.GetBytes(SysUtils.Format(AFmt, AArgs, AFormatSettings));
  Write(VBytes, System.Length(VBytes));
end;
{$IFDEF FPC}{$POP}{$ENDIF}

procedure TBrookString.Format(const AFmt: string; const AArgs: array of const;
  AFormatSettings: TFormatSettings);
begin
  Format(AFmt, AArgs, AFormatSettings, TEncoding.UTF8);
end;

procedure TBrookString.Format(const AFmt: string; const AArgs: array of const);
begin
  Format(AFmt, AArgs, FormatSettings, TEncoding.UTF8);
end;

{$IFDEF FPC}{$PUSH}{$WARN 4105 OFF}{$ENDIF}
function TBrookString.AsText(AEncoding: TEncoding): string;
var
  VBytes: TBytes;
  VLength: NativeUInt;
begin
  CheckEncoding(AEncoding);
  VLength := GetLength;
  SetLength(VBytes, VLength);
  Read(VBytes, VLength);
  Result := AEncoding.GetString(VBytes, 0, VLength);
end;
{$IFDEF FPC}{$POP}{$ENDIF}

function TBrookString.AsText: string;
begin
  Result := AsText(TEncoding.UTF8);
end;

procedure TBrookString.Clear;
begin
  CheckHandle;
  CheckOSError(bk_str_clear(Fstr));
end;

function TBrookString.GetLength: NativeUInt;
begin
  CheckHandle;
  CheckOSError(bk_str_length(Fstr, @Result));
end;

function TBrookString.GetContent: TBytes;
begin
  Result := TMarshal.ToBytes(bk_str_content(Fstr), GetLength);
end;

end.