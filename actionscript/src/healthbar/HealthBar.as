package healthbar {
import common.BaseControl;

import flash.events.Event;
import flash.events.TimerEvent;
import flash.geom.ColorTransform;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.utils.Timer;

import scaleform.gfx.Extensions;

public class HealthBar extends BaseControl {

	private var m_healthBarView:HealthBarView = new HealthBarView();
	private var m_healthBarColourTransform:ColorTransform = new ColorTransform();
	private var m_infectedColourTransform:ColorTransform = new ColorTransform();
	private var m_currentHealthBar:Number;
	private var m_isInfected:Boolean = false;
	private var m_lowHealthColour:uint;
	private var m_mediumHealthColour:uint;
	private var m_fullHealthColour:uint;
	private var m_infectedColour:uint;
	private var m_mediumHealthRatio:Number;

	private var checkCallEntityTimer:Timer;

	// Debug thing
	private var mainColoursObjectDebug:Object;
	private var secondaryColoursObjectDebug:Object;

	private var m_debugTextField:TextField;

	public function HealthBar() {
		Extensions.setEdgeAAMode(m_healthBarView, Extensions.EDGEAA_OFF);

		m_debugTextField = new TextField();
		m_debugTextField.visible = false;
		m_debugTextField.wordWrap = true;
		m_debugTextField.multiline = true;
		m_debugTextField.width = 400;
		m_debugTextField.height = 500;
		m_debugTextField.x = 300;
		m_debugTextField.y = -250;

		var m_debugTextFieldFormat:TextFormat = new TextFormat();
		m_debugTextFieldFormat.size = 18;
		m_debugTextFieldFormat.font = "$medium";
		m_debugTextFieldFormat.color = 0xffffff;
		m_debugTextField.defaultTextFormat = m_debugTextFieldFormat;

		WaitForCallEntity();

		addChild(m_healthBarView);
		addChild(m_debugTextField);
	}

	private function WaitForCallEntity():void {
		checkCallEntityTimer = new Timer(100, 0);
		checkCallEntityTimer.addEventListener(TimerEvent.TIMER, checkCallEntity);
		checkCallEntityTimer.start();
	}

	private function checkCallEntity(event:TimerEvent):void {
		if (CallEntity != null) {
			checkCallEntityTimer.stop();
			checkCallEntityTimer.removeEventListener(TimerEvent.TIMER, checkCallEntity);
			send_RequestData();
		}
	}

	public function send_RequestData():void {
		sendEvent("RequestData");
	}

	public function MainColours(object:Object):void {
		LowHealthColour = object.MainColours.LowHealthColour;
		MediumHealthColour = object.MainColours.MediumHealthColour;
		FullHealthColour = object.MainColours.FullHealthColour;
		InfectedColour = object.MainColours.InfectedColour;
		m_mediumHealthRatio = object.MainColours.MediumHealthRatio;
		UpdateHealthBarColour();
		mainColoursObjectDebug = object.MainColours;
	}

	public function SecondaryColours(object:Object):void {
		HealthBarTextColour = object.SecondaryColours.HealthBarTextColour;
		HealthBarTextBGColour = object.SecondaryColours.HealthBarTextBGColour;
		HealthBarTextBorderColour = object.SecondaryColours.HealthBarTextBorderColour;
		HealthBarBGColour = object.SecondaryColours.HealthBarBGColour;
		HealthBarBorderColour = object.SecondaryColours.HealthBarBorderColour;
		secondaryColoursObjectDebug = object.SecondaryColours;
	}

	public function SetBarHealth(health:Number):void {
		m_currentHealthBar = health;
		UpdateHealth();
	}

	public function SetTextHealth(health:Number):void {
		m_healthBarView.HealthBarText.text = String(Math.round(health));
	}

	public function SetInfected(isInfected:Boolean):void {
		m_isInfected = isInfected;

		if (isInfected) {
			m_healthBarView.HealthBarInner.gotoAndPlay(2);
		} else {
			m_healthBarView.HealthBarInner.gotoAndPlay(1);
		}

		UpdateHealthBarColour();
	}

	private function UpdateHealth():void {
		m_healthBarView.HealthBarInner.scaleY = m_currentHealthBar;
		UpdateHealthBarColour();
	}

	private function UpdateHealthBarColour():void {
		if (m_isInfected) {
			m_infectedColourTransform.color = m_infectedColour;
			m_healthBarView.HealthBarInner.transform.colorTransform = m_infectedColourTransform;
			return;
		}

		var healthRatio:Number = m_currentHealthBar;

		var low:uint, medium:uint, full:uint;

		if (healthRatio <= m_mediumHealthRatio) {
			var lowToMiddleRatio:Number = healthRatio / m_mediumHealthRatio;
			low = interpolate((m_lowHealthColour >> 16) & 0xFF, (m_mediumHealthColour >> 16) & 0xFF, lowToMiddleRatio);
			full = interpolate((m_lowHealthColour >> 8) & 0xFF, (m_mediumHealthColour >> 8) & 0xFF, lowToMiddleRatio);
			medium = interpolate(m_lowHealthColour & 0xFF, m_mediumHealthColour & 0xFF, lowToMiddleRatio);
		} else {
			var middleToFullRatio:Number = (healthRatio - m_mediumHealthRatio) / (1 - m_mediumHealthRatio);
			low = interpolate((m_mediumHealthColour >> 16) & 0xFF, (m_fullHealthColour >> 16) & 0xFF, middleToFullRatio);
			full = interpolate((m_mediumHealthColour >> 8) & 0xFF, (m_fullHealthColour >> 8) & 0xFF, middleToFullRatio);
			medium = interpolate(m_mediumHealthColour & 0xFF, m_fullHealthColour & 0xFF, middleToFullRatio);
		}

		m_healthBarColourTransform.color = (low << 16) | (full << 8) | medium;
		m_healthBarView.HealthBarInner.transform.colorTransform = m_healthBarColourTransform;
	}

	private function interpolate(start:uint, end:uint, ratio:Number):uint {
		return start + (end - start) * ratio;
	}

	private function parseRGB(rgba:String):uint {
		if (rgba.charAt(0) == "#") {
			rgba = rgba.substring(1);
		}

		var colourValue:uint = parseInt(rgba.substr(0, 6), 16);

		return colourValue;
	}

	private function set HealthBarTextColour(colour:String):void {
		var colourValue:uint = parseRGB(colour);
		m_healthBarView.HealthBarText.textColor = colourValue;
	}

	private function set HealthBarTextBGColour(colour:String):void {
		var colourValue:uint = parseRGB(colour);
		var colorTransform:ColorTransform = new ColorTransform();
		colorTransform.color = colourValue;
		m_healthBarView.HealthBarTextBG.transform.colorTransform = colorTransform;
	}

	private function set HealthBarTextBorderColour(colour:String):void {
		var colourValue:uint = parseRGB(colour);
		var colorTransform:ColorTransform = new ColorTransform();
		colorTransform.color = colourValue;
		m_healthBarView.HealthBarTextBorder.transform.colorTransform = colorTransform;
	}

	private function set HealthBarBGColour(colour:String):void {
		var colourValue:uint = parseRGB(colour);
		var colorTransform:ColorTransform = new ColorTransform();
		colorTransform.color = colourValue;
		m_healthBarView.HealthBarBG.transform.colorTransform = colorTransform;
	}

	private function set HealthBarBorderColour(colour:String):void {
		var colourValue:uint = parseRGB(colour);
		var colorTransform:ColorTransform = new ColorTransform();
		colorTransform.color = colourValue;
		m_healthBarView.HealthBarBorder.transform.colorTransform = colorTransform;
	}

	private function set LowHealthColour(colour:String):void {
		var colourValue:uint = parseRGB(colour);
		m_lowHealthColour = colourValue;
	}

	private function set MediumHealthColour(colour:String):void {
		var colourValue:uint = parseRGB(colour);
		m_mediumHealthColour = colourValue;
	}

	private function set FullHealthColour(colour:String):void {
		var colourValue:uint = parseRGB(colour);
		m_fullHealthColour = colourValue;
	}

	private function set InfectedColour(colour:String):void {
		var colourValue:uint = parseRGB(colour);
		m_infectedColour = colourValue;
	}

	public function set DebugMode(bool:Boolean):void {
		if (bool) {
			addEventListener(Event.ENTER_FRAME, UpdateDebugText);
			m_debugTextField.visible = true;
		} else {
			removeEventListener(Event.ENTER_FRAME, UpdateDebugText);
			m_debugTextField.visible = false;
		}
	}

	public function set Height(number:Number):void {
		m_healthBarView.scaleY = number;
	}

	public function set Width(number:Number):void {
		m_healthBarView.scaleX = number;
	}

	private function UpdateDebugText(e:Event):void {
		var debugInfo:String = "";
		debugInfo += "Current Health: " + m_healthBarView.HealthBarText.text + "\n";
		debugInfo += "Is Infected: " + m_isInfected + "\n";
		if (mainColoursObjectDebug != null) {
			debugInfo += "Main colours:\n";
			debugInfo += "\tLowHealthColour: " + mainColoursObjectDebug.LowHealthColour + "\n";
			debugInfo += "\tMediumHealthColour: " + mainColoursObjectDebug.MediumHealthColour + "\n";
			debugInfo += "\tFullHealthColour: " + mainColoursObjectDebug.FullHealthColour + "\n";
			debugInfo += "\tInfectedColour: " + mainColoursObjectDebug.InfectedColour + "\n";
		} else {
			debugInfo += "Main colours:\n";
			debugInfo += "\tLowHealthColour: \n";
			debugInfo += "\tMediumHealthColour: \n";
			debugInfo += "\tFullHealthColour: \n";
			debugInfo += "\tInfectedColour: \n";
		}
		if (secondaryColoursObjectDebug != null) {
			debugInfo += "Secondary colours:\n";
			debugInfo += "\tHealthBarTextColour: " + secondaryColoursObjectDebug.HealthBarTextColour + "\n";
			debugInfo += "\tHealthBarTextBGColour: " + secondaryColoursObjectDebug.HealthBarTextBGColour + "\n";
			debugInfo += "\tHealthBarTextBorderColour: " + secondaryColoursObjectDebug.HealthBarTextBorderColour + "\n";
			debugInfo += "\tHealthBarBGColour: " + secondaryColoursObjectDebug.HealthBarBGColour + "\n";
			debugInfo += "\tHealthBarBorderColour: " + secondaryColoursObjectDebug.HealthBarBorderColour + "\n";
		} else {
			debugInfo += "Secondary colours:\n";
			debugInfo += "\tHealthBarTextColour: \n";
			debugInfo += "\tHealthBarTextBGColour: \n";
			debugInfo += "\tHealthBarTextBorderColour: \n";
			debugInfo += "\tHealthBarBGColour: \n";
			debugInfo += "\tHealthBarBorderColour: \n";
		}

		m_debugTextField.text = debugInfo;
	}

}
}
