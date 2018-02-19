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

{ All utility functions of the library. }

unit BrookUtils;

{$I Brook.inc}

interface

uses
  libbrook,
  Marshalling;

{
  Returns the library version number.
  @return Library version packed into a single integer.
}
function BrookVersion: Cardinal;

{
  Returns the library version number as string.
  @return Library version packed into a static string.
}
function BrookVersionStr: string;

{
  Allocates a new memory space and zero-initialize it.
  @param(ASize[in] Memory size to be allocated.)
  @return(Pointer of the allocated zero-initialized memory; @code(NULL) When
  size is @code(0) or no memory space.)
}
function BrookAlloc(ASize: NativeUInt): Pointer;

{
  Frees a memory space previous allocated by BrookAlloc().
  @param APtr[in] Pointer of the memory to be freed.
}
procedure BrookFree(APtr: Pointer);

implementation

function BrookVersion: Cardinal;
begin
  Exit(bk_version);
end;

function BrookVersionStr: string;
begin
  Exit(TMarshal.ToString(bk_version_str));
end;

function BrookAlloc(ASize: NativeUInt): Pointer;
begin
  Exit(bk_alloc(ASize));
end;

procedure BrookFree(APtr: Pointer);
begin
  bk_free(APtr);
end;

end.