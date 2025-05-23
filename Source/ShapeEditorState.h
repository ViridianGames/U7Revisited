#ifndef _SHAPEEDITORSTATE_H_
#define _SHAPEEDITORSTATE_H_

#include "Geist/State.h"
#include "Geist/Gui.h"
#include "Geist/RaylibModel.h"
#include <list>
#include <deque>
#include <math.h>

class ShapeEditorState : public State
{
public:
   ShapeEditorState(){};
   ~ShapeEditorState();


   virtual void Init(const std::string& configfile);
   virtual void Shutdown();
   virtual void Update();
   virtual void Draw();

   virtual void OnEnter();
   virtual void OnExit();

   int SetupCommonGui(Gui* gui);
   void SetupBboardGui();
   void SetupFlatGui();
   void SetupCuboidGui();
   void SetupMeshGui();
   void SetupCharacterGui();
   void SetupShapePointerGui();
   void SetupDontDrawGui();

   void ChangeGui(Gui* newGui);
   void SwitchToGuiForDrawType(ShapeDrawType drawType);
      
   unsigned int m_currentShape = 0;
   unsigned int m_currentFrame = 0;
   std::map<std::string, std::unique_ptr<RaylibModel>>::iterator m_modelIndex;
   bool m_rotating = false;
   bool m_tileX = false;
   bool m_tileZ = false;
   bool m_shapeTableMade = false;
   float m_rotateAngle = 0.0;

   std::vector<std::vector<std::unique_ptr<U7Object>>> m_objectLibrary;

   std::unique_ptr<Gui> m_bboardGui;
   std::unique_ptr<Gui> m_flatGui;
   std::unique_ptr<Gui> m_cuboidGui;
   std::unique_ptr<Gui> m_meshGui;
   std::unique_ptr<Gui> m_characterGui;
   std::unique_ptr<Gui> m_shapePointerGui;
   std::unique_ptr<Gui> m_dontDrawGui;

   Gui* m_currentGui = nullptr;

   std::string m_sideDrawStrings[7];
   std::string m_sideStrings[6];

   int m_luaScriptIndex = 0;

   // DEEP BREATH

   enum GuiElements
   {
      GE_TITLETEXT = 0,

      GE_PANELBORDER,
      GE_PANEL,

      GE_PREVSHAPEBUTTON,
      GE_NEXTSHAPEBUTTON,
      GE_CURRENTSHAPEIDTEXTAREA,

      GE_PREVFRAMEBUTTON,
      GE_NEXTFRAMEBUTTON,
      GE_CURRENTFRAMEIDTEXTAREA,

      GE_COPYPARAMSFROMFRAME0,

      GE_DRAWTYPELABEL,
      GE_PREVDRAWTYPE,
      GE_NEXTDRAWTYPE,
      GE_CURRENTDRAWTYPETEXTAREA,

      GE_TOPTEXTAREA,
      GE_TOPRESET,
      GE_TOPXPLUSBUTTON,
      GE_TOPXMINUSBUTTON,
      GE_TOPXTEXTAREA,
      GE_TOPYPLUSBUTTON,
      GE_TOPYMINUSBUTTON,
      GE_TOPYTEXTAREA,
      GE_TOPWIDTHPLUSBUTTON,
      GE_TOPWIDTHMINUSBUTTON,
      GE_TOPWIDTHTEXTAREA,
      GE_TOPHEIGHTPLUSBUTTON,
      GE_TOPHEIGHTMINUSBUTTON,
      GE_TOPHEIGHTTEXTAREA,

      GE_FRONTTEXTAREA,
      GE_FRONTRESET,
      GE_FRONTXPLUSBUTTON,
      GE_FRONTXMINUSBUTTON,
      GE_FRONTXTEXTAREA,
      GE_FRONTYPLUSBUTTON,
      GE_FRONTYMINUSBUTTON,
      GE_FRONTYTEXTAREA,
      GE_FRONTWIDTHPLUSBUTTON,
      GE_FRONTWIDTHMINUSBUTTON,
      GE_FRONTWIDTHTEXTAREA,
      GE_FRONTHEIGHTPLUSBUTTON,
      GE_FRONTHEIGHTMINUSBUTTON,
      GE_FRONTHEIGHTTEXTAREA,

      GE_RIGHTTEXTAREA,
      GE_RIGHTRESET,
      GE_RIGHTXPLUSBUTTON,
      GE_RIGHTXMINUSBUTTON,
      GE_RIGHTXTEXTAREA,
      GE_RIGHTYPLUSBUTTON,
      GE_RIGHTYMINUSBUTTON,
      GE_RIGHTYTEXTAREA,
      GE_RIGHTWIDTHPLUSBUTTON,
      GE_RIGHTWIDTHMINUSBUTTON,
      GE_RIGHTWIDTHTEXTAREA,
      GE_RIGHTHEIGHTPLUSBUTTON,
      GE_RIGHTHEIGHTMINUSBUTTON,
      GE_RIGHTHEIGHTTEXTAREA,

      GE_FRONTSIDETEXTAREA,
      GE_RIGHTSIDETEXTAREA,
      GE_TOPSIDETEXTAREA,
      GE_BACKSIDETEXTAREA,
      GE_LEFTSIDETEXTAREA,
      GE_BOTTOMSIDETEXTAREA,

      GE_NEXTFRONTBUTTON,
      GE_NEXTRIGHTBUTTON,
      GE_NEXTTOPBUTTON,
      GE_NEXTBACKBUTTON,
      GE_NEXTLEFTBUTTON,
      GE_NEXTBOTTOMBUTTON,

      GE_PREVFRONTBUTTON,
      GE_PREVRIGHTBUTTON,
      GE_PREVTOPBUTTON,
      GE_PREVBACKBUTTON,
      GE_PREVLEFTBUTTON,
      GE_PREVBOTTOMBUTTON,

      GE_FRONTSIDETEXTURETEXTAREA,
      GE_RIGHTSIDETEXTURETEXTAREA,
      GE_TOPSIDETEXTURETEXTAREA,
      GE_BACKSIDETEXTURETEXTAREA,
      GE_LEFTSIDETEXTURETEXTAREA,
      GE_BOTTOMSIDETEXTURETEXTAREA,

      GE_SAVEBUTTON,
      GE_LOADBUTTON,

      GE_TWEAKPOSITIONTEXTAREA,

      GE_TWEAKXTEXTAREA,
      GE_TWEAKXPLUSBUTTON,
      GE_TWEAKXMINUSBUTTON,

      GE_TWEAKYTEXTAREA,
      GE_TWEAKYPLUSBUTTON,
      GE_TWEAKYMINUSBUTTON,

      GE_TWEAKZTEXTAREA,
      GE_TWEAKZPLUSBUTTON,
      GE_TWEAKZMINUSBUTTON,

      GE_TWEAKDIMENSIONSTEXTAREA,

      GE_TWEAKWIDTHTEXTAREA,
      GE_TWEAKWIDTHPLUSBUTTON,
      GE_TWEAKWIDTHMINUSBUTTON,

      GE_TWEAKHEIGHTTEXTAREA,
      GE_TWEAKHEIGHTPLUSBUTTON,
      GE_TWEAKHEIGHTMINUSBUTTON,

      GE_TWEAKDEPTHTEXTAREA,
      GE_TWEAKDEPTHPLUSBUTTON,
      GE_TWEAKDEPTHMINUSBUTTON,

      GE_TEXTUREASSIGNMENTTEXTAREA,

      GE_MODELTEXTAREA,
      GE_NEXTMODELBUTTON,
      GE_PREVMODELBUTTON,
      GE_MODELNAMETEXTAREA,

      GE_TWEAKROTATIONTITLEAREA,
      GE_TWEAKROTATIONTEXTAREA,
      GE_TWEAKROTATIONPLUSBUTTON,
      GE_TWEAKROTATIONMINUSBUTTON,

      GE_MESHOUTLINECHECKBOX,
      GE_MESHOUTLINETEXTAREA,

      GE_USESHAPEPOINTERCHECKBOX,
      GE_USESHAPEPOINTERTEXTAREA,

      GE_PREVSHAPEPOINTERBUTTON,
      GE_NEXTSHAPEPOINTERBUTTON,
      GE_CURRENTSHAPEPOINTERIDTEXTAREA,

      GE_PREVFRAMEPOINTERBUTTON,
      GE_NEXTFRAMEPOINTERBUTTON,
      GE_CURRENTFRAMEPOINTERIDTEXTAREA,

      GE_JUMPTOINSTANCE,

      GE_LUASCRIPTLABEL,
      GE_PREVLUASCRIPTBUTTON,
      GE_LUASCRIPTTEXTAREA,
      GE_NEXTLUASCRIPTBUTTON,

      GE_OPENLUASCRIPTBUTTON,
      GE_SETLUASCRIPTTOSHAPEIDBUTTON,

      GE_LASTGUIELEMENT
   };

};

#endif